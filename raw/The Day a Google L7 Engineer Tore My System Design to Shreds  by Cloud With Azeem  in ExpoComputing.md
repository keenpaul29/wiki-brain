---
title: "The Day a Google L7 Engineer Tore My System Design to Shreds | by Cloud With Azeem | in ExpoComputing"
source: "https://freedium-mirror.cfd/medium.com/expocomputing/google-l7-system-design-interview-lessons-0b3834fded07"
author:
published:
created: 2026-05-26
description: "If you are not medium member read here for free"
tags:
  - "clippings"
---
[< Go to the original](https://medium.com/expocomputing/google-l7-system-design-interview-lessons-0b3834fded07#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/1*NVtpplR8n3E_HuwZG88Lmw.png)

## The Day a Google L7 Engineer Tore My System Design to Shreds

## If you are not medium member read here for free[ExpoComputing](https://medium.com/expocomputing "ExpoComputing is a modern tech publication focused on Cloud…")a11y-light ~7 min read · February 16, 2026 (Updated: February 16, 2026) · Free: No

> @ [Cloud With Azeem](https://medium.com/u/f34a895a19b4), @ [Azeem Teli](https://medium.com/u/786a45a27c54), #expocomputing

I walked into the interview room with the quiet confidence of someone who had "beaten" the system. I had memorized the blueprints. I knew the difference between MongoDB and Cassandra, I could draw a Content Delivery Network (CDN) in my sleep, and I had the Netflix tech stack etched into my brain like a holy text. I was ready to talk about microservices, sharding, and high availability.

Then I met the interviewer — a soft-spoken L7 Staff Engineer who had spent the last decade keeping systems alive that handle more traffic in a second than most apps see in a year.

The problem he gave me was deceptively simple: **"Design a URL shortener."**

I smirked. This was the "Hello World" of system design. I grabbed the marker and started flying through the motions. API Gateway here, Load Balancer there, a NoSQL database for the mapping, and a Redis cache to keep things snappy. I was talking about **$O(1)$ lookups** and **Base62** encoding. I felt like a rockstar.

Then he leaned forward. "This looks great for a startup with a few thousand users. But what happens to your architecture when we hit **10 million writes per second**? And specifically, how does your chosen database handle the **write-ahead log (WAL)** contention at that scale?"

The marker stopped mid-air. I felt a cold drop of sweat. I knew the patterns, but I didn't know the *physics* of the systems I was drawing. I realized I was just a "paper architect" — someone who could draw the map but had never actually walked the terrain.

### The Mirage of Pattern Matching

Most of us fall into the **Pattern Trap**. We study system design by looking at how the "Big Giants" do it. We see that LinkedIn moved away from certain legacy systems, or we read about the [LinkedIn Kafka replacement and their new streaming system](https://medium.com/@cloudwithazeem/linkedin-kafka-replacement-new-streaming-system-76e56073eb97?source=user_profile_page---------3-------------f34a895a19b4----------------------), and we immediately think, "Okay, if LinkedIn did it, I should do it too."

![None](https://miro.medium.com/v2/resize:fit:700/0*LPLffuvMS9DlBPgk.png)

But an L7 interviewer doesn't care if you can copy LinkedIn. They care if you understand *why* LinkedIn had to move.

> **The Analogy of the Master Chef vs. The Line Cook**

> Think of system design like cooking. A line cook follows a recipe (the pattern). If the recipe says "add salt," they add salt. But a Master Chef understands the chemistry. If the tomatoes are more acidic today, they adjust the sugar. They don't follow the recipe blindly; they respond to the ingredients.

In system design, your "ingredients" are your constraints:

- **Latency budgets** (How fast?)
- **Throughput requirements** (How much?)
- **Data consistency** (How accurate?)

If you can't tell me why you chose a specific tool — like why you might be [moving away from Terraform](https://medium.com/@cloudwithazeem/moving-away-from-terraform-76766966bb05?source=user_profile_page---------2-------------f34a895a19b4----------------------) in favor of something more programmatic or state-managed — then you aren't designing. You're just reciting.

### When Horizontal Scaling Isn't the Answer

One of the biggest "aha!" moments in that interview came when we discussed scaling. I kept saying, "We'll just add more nodes." Horizontal scaling is the universal band-aid of junior-to-mid-level engineers.

The interviewer stopped me. "Every time you add a node, you add a network hop. Every network hop adds a percentage chance of failure. At what point does the 'coordination overhead' of your 1,000 nodes become slower than a single, highly-optimized vertical machine?"

#### The Case Study: The "Thundering Herd" Problem

Imagine a world-famous bakery that gives away free cupcakes at 9:00 AM. If you have one door, everyone crowds the door (Vertical bottleneck). If you add ten doors (Horizontal scaling), the crowd spreads out. But what if all ten doors lead to the same single tray of cupcakes? Now, you have ten times the people rushing a single point of contention, causing a crush.

In a URL shortener, if you have a viral link (like a Super Bowl ad), every single one of your "scaled-out" app servers is going to hammer the same row in your database or the same key in your cache. This is the **Hot Key** problem. Adding more servers actually makes it *worse* because you're increasing the volume of simultaneous requests hitting that one bottleneck.

To solve this, you don't just "scale." You might implement **request collapsing** (where multiple identical requests wait for a single database read) or **adaptive caching**. This is the level of thinking that separates a Senior from a Staff engineer.

### The Architecture of Failure: Reasoning Through Chaos

The Google L7 didn't ask "How does this work?" He asked "How does this break?"

He pushed me into a corner: "Your primary database in US-East just caught fire. Your failover to US-West is happening, but the network link is throttled to 10% capacity. What do your users see?"

I realized I hadn't thought about **State Inconsistency**. In my head, "failover" was a magic button. In reality, it's a messy, data-losing nightmare if not handled correctly. This is where the debate of [Monolith vs. Microservices](https://medium.com/@cloudwithazeem/monolith-vs-microservices-scalability-netflix-case-study-c8fc8651b98d?source=user_profile_page---------1-------------f34a895a19b4----------------------) becomes real. In a monolith, you have one big failure. In microservices, you have a thousand tiny, cascading failures that are much harder to debug.

#### Case Study Overview: The Netflix Chaos Monkey

![Case Study Overview: The Netflix Chaos Monkey](https://miro.medium.com/v2/resize:fit:700/0*tXPKebtKBJa_U6C8.jpg)

Netflix is famous for this. They realized that in a distributed system, failure isn't a possibility; it's a certainty. They built " [Chaos Monkey](https://netflix.github.io/chaosmonkey/) " to randomly shut down servers in production. Why? To force their engineers to design systems that are **self-healing**.

If I'm designing a URL shortener for 10 million writes/sec, I have to assume:

1. The cache will go down.
2. The disk will fill up.
3. The "short code" generator will produce a duplicate.

If your design doesn't include a plan for when the "Black Swan" event happens, your design is just a fantasy.

### The Power of "No-Cache" Thinking

The most humbling moment was when the interviewer challenged my reliance on Redis. "Design this without a distributed cache," he said.

> I was stunned. "But… the latency would be terrible!"

"Would it?" he countered. "If 90% of your shortened URLs are clicked only once (the 'long tail' of data), then your cache hit rate is only 10%. In that case, your cache is actually *slowing you down* because every request checks the cache, misses, and then goes to the database. You've added 5ms of overhead to 90% of your traffic for no reason."

This blew my mind. I had been taught that **Cache = Fast**. But in reality:

> ***Effective Latency = (Hit Rate x Cache Latency) + ((1 — Hit Rate) x DB Latency)***

If the Hit Rate is low, the overhead of managing a distributed cache (and the risk of stale data) outweighs the benefits. He wanted to see if I could be brave enough to say, "We don't need a cache here yet."

### Engineering is the Art of Trade-offs

By the end of the two hours, my whiteboard was a mess of crossed-out boxes and rewritten logic. But for the first time, the design felt *real*. It wasn't a textbook diagram; it was a battle-hardened plan.

I learned that System Design is not about finding the "right" answer. There is no right answer. There are only **trade-offs**.

- **Consistency vs. Availability:** Do you want the user to see the exact right data, or do you want the page to load even if the data is a few seconds old?
- **Latency vs. Cost:** Do you want it to be sub-10ms, or do you want to stay within budget?
- **Complexity vs. Maintainability:** Do you want a "perfect" system with 50 microservices, or something three engineers can actually manage without burning out?

### How to Actually Prepare for the L7 Level

If you want to move beyond just "memorizing patterns," you need to change how you study.

1. **Don't just draw the box — explain the cost.** Every time you add a Load Balancer or a Message Queue, ask yourself: "What is the dollar cost, the latency cost, and the maintenance cost of this addition?"
2. **Start with the "Naked" System.** Design the whole thing with just one server and one database. Then, only add complexity when the numbers prove you've run out of room.
3. **Learn the Math.** You don't need to be a mathematician, but you should know how to estimate QPS (Queries Per Second), storage requirements for 5 years, and bandwidth needs.
4. **Study Real Outages.** Read the post-mortems of companies like AWS, Cloudflare, and Slack. See how their "perfect" designs failed in the real world. That is where the true learning happens.

Stop collecting patterns like Pokemon cards. Start understanding the "why" behind every line you draw. Because in the real world — and in high-level interviews — the whiteboard doesn't care about your diagrams; it cares about your logic.

[< Go to the original](https://medium.com/expocomputing/google-l7-system-design-interview-lessons-0b3834fded07#bypass)