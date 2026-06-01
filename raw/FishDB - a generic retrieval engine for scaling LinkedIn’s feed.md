---
title: "FishDB: a generic retrieval engine for scaling LinkedIn’s feed"
source: "https://www.linkedin.com/blog/engineering/infrastructure/fishdb-a-generic-retrieval-engine-for-scaling-linkedins-feed"
author:
published: 2025-11-17
created: 2026-06-01
description:
tags:
  - "clippings"
---
LinkedIn’s feed is a critical part of our members’ experience, helping them connect with their network and discover relevant content and knowledge. That’s why it’s important for us to deliver content efficiently and reliably while maintaining the flexibility to support evolving product needs.

For nearly a decade, [FollowFeed](https://www.linkedin.com/blog/engineering/feed/followfeed-linkedin-s-feed-made-faster-and-smarter) (a Java application optimized to serve connection-based feed content) powered all of LinkedIn’s feed experiences. However, as the scale and sophistication of use cases grew, its architecture began to show limitations, prompting us to replace FollowFeed with FishDB. FishDB is a generic retrieval engine, written in Rust, designed to meet the demands of modern recommender systems.

This blog post chronicles our multi-year journey to implement FishDB and how it’s helping us achieve 2x efficiency and reducing hardware usage for the feed by 50% – all while offering more flexible APIs and maintaining our demanding latency SLOs. We’ll also highlight FishDB’s architecture and the decisions we made throughout the migration process.

## Why we needed a new system

FollowFeed’s limitations fell into two major categories: *scalability* and *platform usability*.

### Scalability bottlenecks

- **Memory inefficiency**: FollowFeed relied on a Java-based [Caffeine cache](https://github.com/ben-manes/caffeine) to store in-memory objects. Due to Java’s object representation overhead, especially for non-primitive types, there was significant memory wasted and reduced cache capacity. Our analysis showed that ~18% of our Java heap memory was from object overhead.
- **Content duplication**: Feed activities are inherently graph-like (e.g. a comment referencing a repost of a post). FollowFeed’s schema stored full copies of referenced content in each leaf document, resulting in ~1.7x duplication on average per document within a shard.
- **Tail latency issues**: Java’s garbage collection introduced unpredictable and high p999 latencies. In distributed systems, high downstream fanout significantly impacts latency by increasing the likelihood of encountering long-tail latencies (e.g., p99 or p999) in a downstream service. With FollowFeed already operating at a large partition count (48 partitions), it is nearly certain that at least one partition within a request will return at its p999 latency.

### Platform usability constraints

- **Rigid data model**: FollowFeed used a fixed record schema that made assumptions about the feed’s data model; which didn’t necessarily hold for newer content types. This made schema evolution cumbersome and led to tech debt across the entire stack when shoehorning new requirements into this data model.
- **Coupled business logic**: Filtering logic was tightly wired within the system, requiring product teams to write custom Java classes. This slowed iteration velocity and frequently blocked feature rollouts due to the slower deployment cycles of a stateful distributed system.
- **Limited algorithm flexibility**: Any significant changes to retrieval algorithms required deep involvement from the infrastructure team, creating bottlenecks for quick experimentation.

These challenges motivated us to build FishDB as a generic system and adopt a native coding language to improve scalability and efficiency.

## Why Rust?

As we scaled LinkedIn’s feed infrastructure, we ran into performance bottlenecks caused by the Java Virtual Machine (JVM) and its garbage collector. These inefficiencies made it clear that we needed a native programming language that offers fine-grained control over memory management. To validate this direction, we ran an experiment comparing in-memory cache usage between Java and Rust. The results were striking: storing 60 million keys in Java required nearly 5x more memory than Rust to hold the same data. This confirmed our hypothesis and gave us confidence to move forward.

We had optimized our java memory model in the past, to minimize object header overhead, learnings from this effort are captured in the [Tuning for High Performances](https://www.linkedin.com/blog/engineering/infrastructure/java-heap-memory-and-garbage-collection-tuning-for-high-performance-services) blog. We evaluated using a serialized representation in Java to completely eliminate object header overhead but ruled out this approach as it was adding latency/garbage collector overhead from temporary object creation during request processing.

When evaluating C++ vs Rust, Rust’s strong memory safety guarantees stood out - especially for a team transitioning from a Java background. Rust’s ownership model helped us avoid common pitfalls like memory leaks and race conditions, without sacrificing performance.

## Overview of FishDB

At a high level, FishDB uses a typical scatter-gather architecture, with a broker layer that fans out requests to N partitioned shards (as seen in Fig 1 below). The responses from these N partitions are aggregated and the top K results are sent back to the caller. Any broker can talk to any of the M replicas of each partition (through an internal load balancing and service discovery protocol). Data is partitioned by a user-specified key within the document data - for the feed use case, we use actor ID as the partitioning key and currently have 16 replicas with 48 partitions per replica.

Fig 1. Scatter-gather architecture of FishDB

For indexing and ingesting data into FishDB, we adopted a [lambda architecture](https://en.wikipedia.org/wiki/Lambda_architecture) (as seen in Fig 2 below). It leverages offline batch processing to build an index over the entire dataset and then real-time stream processing to keep the index up-to-date while serving. We expect users of the system to provide two inputs:

1. A batch source for their data (typically an ETL stored in HDFS) which then gets processed in bulk by a FishDB indexing process. This process outputs partitioned index files which can be downloaded and loaded by a corresponding shard.
2. A data stream (typically a Kafka topic) which gets repartitioned by the domain specific partitioning-key. Each partition of this resulting stream is then ingested by the corresponding FishDB shard to keep the index up to date.

The ability to rebuild an index from a batch source allows us to easily backfill data or evolve the document schema - one of the pain points we were trying to solve.

Fig 2. Data ingestion path for FishDB

## Query capabilities

One goal for FishDB is to offer a powerful and extensible query language that allows users to express their filtering and ranking business logic. We have implemented an initial imperative version which is more akin to a “physical query plan” in traditional database terminology. We expect to evolve this query interface into a proper declarative language with query planning/optimization layers in the future. Below, we’ll cover the basic structure of a query and highlight some of the key capabilities.

### Syntax

Queries follow a functional programming style where a query is just a composition of functions. We also support higher order functions which can take lambda expressions as inputs. The basic syntax is as follows:

```
function_name(arg1 arg2 {(var1, var2) -> expression})
```

Where *function\_name* is an operation and *arg1, arg2, etc* can be literals, variables, other function calls, or a lambda function. The third argument demonstrates how to construct a lambda function which takes *var1, var2* as input and evaluates to the given *expression* (which can use any variables that are in scope).

For example:

```
filter({ (doc_id) -> eq('ACTIVE' readdoc(doc_id 'state') } all())
```

The above query scans all indexed documents and applies a filter for state==ACTIVE.

### Selection, filtering, ranking

While relatively simple, this basic construct allows us to express a variety of complex business logic. Furthermore, we can easily extend the set of built-in operations to support different types of data access, boolean logic, mathematical computations, etc. For example, here is a query to “get most viewed movies from 2025 with the comedy or action genre”:

Each part of the query can be extended with more complex logic and additional stages can be chained together (e.g. ranking could use embedding distance or additional filtering could be applied after the top-k). There can also be multiple ways of expressing the same logic. For example, the below query targets the same criteria as the one above, but first applies top-k on movies from the year 2025 and then filters those on genre:

While this gives power to the user to balance latency vs recall, it also puts the onus on them to understand their data characteristics. Hence, as mentioned previously, we are working on a query planning layer to abstract these details away.

### Execution engine

The query engine uses a traditional [Volcano-style iterator model](https://cs-people.bu.edu/mathan/reading-groups/papers-classics/volcano.pdf) to resolve and join posting lists into a set of resulting doc ids. We also implemented a tree-walk interpreter for evaluating lambda expressions. For example, here’s the resulting operator tree for the filter subexpression from above:

Fig 6. Query execution of a filter expression

## Indexes

In this section, we’ll go into more detail about the custom index structures that FishDB provides. It is important to note that the feed use case only retrieves data from the past 30 days, which can entirely fit in memory across our 48 partitions. A single query can contain 300+ inverted terms, selects ~3K candidates, and performs ~150K data accesses for filtering and ranking. Hence we have focused our efforts on choosing and optimizing in-memory data structures which can support these access patterns.

### Inverted Index

Our inverted index is an in-memory hashmap of terms that point to lists of document-ids (in ascending order). We use Rust’s [dashmap](https://github.com/xacrimon/dashmap) library to provide a resizable segmented hashmap that supports concurrent reads & writes to the index with minimal blocking. Writes are batched into a buffer and made visible to readers periodically with copy-on-write semantics - this allows reader threads to hold references to older posting lists for the entire lifetime of a query. Currently our posting list format is just simple arrays, but in the future, we imagine implementing more optimal representations (such as skiplists, which are commonly seen in other search/retrieval systems). Since our feed queries heavily rely on forward-index based filtering, the lack of skiplists has not been a bottleneck yet.

### Forward index

FishDB’s query engine uses a forward index to access document fields for filtering/scoring (e.g. for feed, check an activity’s creation time, content type, etc.). It is optimized for frequent point accesses of dense data.

The primary data-structure is a fixed-capacity array of pointers to documents (ordered by doc ID). The document itself is an immutable collection of fields stored contiguously as encoded bytes (as illustrated in Fig 4 below). Documents are read-only and updates are treated as a delete then add. We chose this row-based storage format because it matches the document-by-document access pattern during query execution (and hence maximizes data locality).

The capacity of the document pointer array is computed on startup, based on the size of the initial index and with sufficient buffer to handle real-time updates. Enforcing a fixed capacity and immutable documents allows us to support lock-free multi-reader, single-writer access using only an atomic counter. This also allows us to access any fixed-sized fields (int, float, enum, etc) in only two memory indirections and variable-sized fields (string, list) in three memory indirections.

Fig 4. FishDB forward index

### Reference index

While the above forward and inverted index provide typical search capabilities, FishDB also provides graph-based filtering by allowing documents to *reference other documents*. The naive approach was to store doc-id references as a field directly in the forward index. But this makes it extremely inefficient to support updates on those referenced documents (an update results in a new doc-id being assigned). Consequently, we had to introduce the concept of a “document reference” (doc-ref) which is essentially a persistent pointer that always points to the latest version of a document (as seen in Fig 5 below). To do so, we created an auxiliary index to store mappings from doc-ref to doc-id. This mapping is updated by writers while the forward index document itself stays immutable. To traverse the document graph using this index, the query engine first fetches the doc-ref from the forward index, uses the doc-ref index to convert it into a doc-id, and then recurses further as needed.

Fig 5. Hierarchical document access

### Attribute stores

A key limitation of the forward index is that all fields should come from the same data source. This can theoretically be worked around by performing data joins upstream. However real-time stream joins are complex to implement and sparse denormalized fields are expensive to store in the forward index. Hence, FishDB provides key-value attribute stores that can support larger volumes of data using a tiered storage strategy. Keys for accessing these stores are usually stored as foreign keys in the forward index and can be used during filtering or ranking (for example, in the feed, we store document embeddings as a ranking feature and spam classification features as sparse filtering attributes).

We opted to use [RocksDB](https://rocksdb.org/) here because it is heavily used at Linkedin and provides various configuration options to implement tiered storage. We want to optimize for sparse, single key lookups and tried tuning RocksDB’s block cache, bloom filter, and compaction settings. However, we ultimately could not achieve the performance we wanted with standalone RocksDB by nature of its [log-structured-merge tree](https://en.wikipedia.org/wiki/Log-structured_merge-tree) (e.g. reducing depth improves read latency but caused significant latency spikes during compaction, and missing keys still incur a bloom filter check at each level of the tree). This led us to add a row-level bloom filter and LRU cache so that most single key lookups do not hit RocksDB at all.

## Reimagining feed architecture with FishDB

The core data model for LinkedIn’s feed is the concept of a **timeline record**: a single unit of content composed of actor, verb, object (AVO), and metadata that describes the activity. These records can form complex chains of references (e.g., a “like” on a “comment” on a “share”), and are indexed into per-actor timelines that can be fetched and joined at serving time to generate personalized candidate sets for viewers.

We can mimic this approach using the generic capabilities of FishDB:

- **Forward index**: Each activity record is stored as a document in the forward index.
- **Document references**: Parent-child relationships between activities are modeled using persistent doc refs, enabling efficient graph traversal.
- **Actor timelines**: Actors are treated as inverted terms, allowing each posting list in the inverted index to represent an actor’s timeline.

This design improves memory efficiency and also enables richer filtering and ranking logic in the future. On the query side, FollowFeed relied heavily on record-by-record filtering. For the initial migration, we translated this logic directly into FishDB’s query language, preserving all existing business rules (such as hiding content from unfollowed entities or filtering out spam). By leveraging FishDB, we’ve laid the groundwork for a more performant, extensible, and developer-friendly feed platform. The differences in data representation is illustrated below:

Fig 7. Legacy FollowFeed data model (left) vs FishDB (right)

## Migration: transition without disruption

Our main goal while migrating from FollowFeed was to ensure a seamless transition with no disruption to member experience, while also delivering incremental platform improvements.

To achieve this, we anchored our strategy around two key tenets:

- **Functional and performance parity**: Every feature was incrementally tested and ramped in production to ensure it did not cause any regressions to member experience.
- **Operational simplicity**:Avoid the burden of maintaining both FollowFeed and FishDB in parallel

We adopted a layered migration approach, transitioning core capabilities - such as candidate retrieval, filtering, and scoring - one at a time to the FishDB Rust layer. We implemented a JNI bridge in order to run native Rust code as part of the original FollowFeed service.

Fig 8. Stages of migration from FollowFeed to FishDB

Since the client APIs still remained the same, this allowed us to incrementally conduct A/B testing between production and test environments. And once parity was confirmed, we fully deployed each new capability. This strategy eliminated the need to run two systems simultaneously and accelerated development and testing cycles. It also simplified debugging by isolating issues to specific capabilities.

By gradually shifting responsibilities from Java-based FollowFeed to Rust-powered FishDB, we ensured a *safe, reliable, and efficient* migration path.

## Conclusion

The development and deployment of FishDB marks a significant milestone in LinkedIn’s journey to modernize its retrieval infrastructure. By replacing the legacy FollowFeed system with a Rust-based, generic engine, we’ve achieved substantial wins in scalability, performance, and platform flexibility. Specifically, we can maintain our *40ms p99 latency* target while supporting *twice the QPS on a single host*. Furthermore, we have unlocked the ability to quickly re-index data and have also decoupled business logic from our infrastructure. This brings experimentation time down from several weeks to several days

What sets FishDB apart from other off-the-shelf counterparts is its flexible query language for complex filtering and its graph-based data modeling. Looking ahead, the team plans to invest more heavily in vector search capabilities and also evolve the query interface into a declarative language with built-in query optimization. Overall, we believe that having an in-house, performant, and customizable retrieval engine will allow us to adopt and explore more modern retrieval techniques across LinkedIn’s products.

## Acknowledgements

Finally, this journey wouldn’t have been possible without the collaboration of several cross-functional teams and the support of our engineering leadership. We’d like to thank everyone who has contributed to this project and helped make it a success:

**Retrieval Engines:** Ken Li Nisheedh Raveendran Pushkar Gupta Emily Ki Shirisha Singh Jack Wang Francisco Claude Pankhuri Goyal Rajeev Kumar Swapnil Rajaram Patil Pratikmohan Srivastav Aman Mehrotra Tanaya Jha Mokshika Mitra Gokulakrishna Shanmugam Tanuma Patra Divyam Rathore Ayush Sharma Aryan Verma Sammed Bhandari OMPRAKASH YADAV Ameya Karve Tulika Saxena Santosh Penubothula Pulak Kuli Aditya Sharma Jaiwant Rawat Siddharth Singh Shubham Jain Vinay Krishnamurthy Rajdeep Das Srikanth R Rahul Saxena

**Ingestion:** Yu Zheng Sanjeev Ojha Sunny Ketkar Vishnusaran Ramaswamy Adam Peck Meling Wu Qian Huang Tianxiong Wang Yuting Chen Shihan Lin Lingyu Zhang Hongbin Wu Yue Ying Tony Hairr

**Feed AI:** Bhargav Patel Frank Shyu Daqi Sun Samaneh Moghaddam

**Reliability Infra:** Joel Stiller Jon Hannah Lester Haynes Tanya Peddi Suman Roy Rajiv Raja

**Feed Serving**: Shunlin Liang Sreekar Bonam Vibhuti Sengar Evan Wu

**Control Plane**: Mehiar Dabbagh William Kinney Deepak Manoharan

**Project Management**: Swathi Varambally Justin Kominar