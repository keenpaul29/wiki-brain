---
title: "The Untold Architecture Behind Production Firewalls: Build Your Own SafeLine in Rust From Zero | by Souradip Pal | in Level Up Coding"
source: https://freedium-mirror.cfd/medium.com/gitconnected/the-untold-architecture-behind-production-firewalls-build-your-own-safeline-in-rust-from-zero-afc25c5c0cd6
author: "[[Souradip Pal]]"
published:
created: 2026-05-26
description: Before You Write a Single match Statement, Understand the Machine You Are Actually Building
tags:
  - clippings
---
[< Go to the original](https://levelup.gitconnected.com/the-untold-architecture-behind-production-firewalls-build-your-own-safeline-in-rust-from-zero-afc25c5c0cd6#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/1*8R6ND0OOvQavTHNQmKMNDQ.jpeg)

## The Untold Architecture Behind Production Firewalls: Build Your Own SafeLine in Rust From Zero

## Before You Write a Single match Statement, Understand the Machine You Are Actually Building[Level Up Coding](https://medium.com/gitconnected "Coding tutorials and news.")a11y-light ~7 min read · May 22, 2026 (Updated: May 22, 2026) · Free: No

> ***Series:*** *The Rust Firewall Files |* ***Part 1 of 5***

Hi, I am Souradip. In 2022 I walked into my first hackathon with zero preparation and somehow ended up winning Smart India Hackathon 2024 two years later, building a satellite data platform for ISRO scientists who were very polite about my lack of knowledge of geospatial formats.

Since then I did an AI internship at SAC ISRO, founded devdotcom.in (a 600-member community where I ran free DSA sessions at 11pm because apparently that is when students are most awake), and I am currently an AI Engineer at CannerAI finishing my B.Tech in CSE.

Right now I am deep into Rust. Two merged PRs in the official toolchain (rust-clippy and rust-analyzer), building Ferrmail as a Resend-competitor in pure Rust, and now writing this series.

The goal is simple: document what it actually looks like to build production-grade security infrastructure in Rust, the way I wish someone had written it when I was starting out. Honest. Detailed. Occasionally unhinged.

### What SafeLine Is and Why We Are Cloning Its Soul

SafeLine is an open source Web Application Firewall built by Chaitin Technology. It sits in front of your web application and reads every HTTP request before your server ever touches it. Someone tries to dump your database through a crafted query parameter?

SafeLine catches it and returns a 403 before your application even wakes up.

It is the kind of system that looks deceptively simple from the outside and contains an entire education in how the internet works once you try to build it yourself.

We are building something inspired by it. Rust. From scratch. Five blog posts.

### The Shape of the System

Before writing a single line of code, spend ten minutes understanding what you are building. I skipped this step on showup.day and spent two days untangling a mess I could have avoided. Do not be me.

```rust
Internet  -->  [Our Rust Firewall]  -->  Your Actual App
```

Every HTTP request from the outside world hits our firewall first. The firewall does five things, in order:

1. Accept the raw TCP connection
2. Parse the HTTP request from raw bytes
3. Run the parsed request through an inspection engine
4. Either forward it to your backend or respond with a 403
5. Log what happened and why

Five steps. But each one contains a real engineering problem worth understanding, and we are going to look at all of them.

### The Five Layers

Our firewall has five distinct layers. Each has one job and hands off to the layer above or below it.

**Layer 1: The TCP Listener.** The lowest layer. This is where raw TCP connections from the internet arrive. We bind a `TcpListener` to port 8080, and every time a client connects, Tokio spawns an async task for that connection. Here is a preview (we build this fully in Part 2):

```rust
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("0.0.0.0:8080").await.unwrap();
    loop {
        let (socket, addr) = listener.accept().await.unwrap();
        tokio::spawn(handle_connection(socket, addr));
    }
}
```

**Layer 2: The HTTP Parser.** TCP gives us bytes. We need a structured request we can reason about. This layer reads bytes off the stream and turns them into a typed Rust struct with method, path, query string, headers, and body. We use the `httparse` crate for this because writing an HTTP parser from scratch in Part 1 of a beginner blog is a great way to lose half your readers.

**Layer 3: The Inspection Engine.** This is the brain. It takes the parsed request and runs it through a series of checks. Some are simple (block requests from this IP), some are complex (detect SQL injection patterns buried inside URL-encoded query parameters). Rules are data, not hardcoded conditions, which is the design decision that makes the whole thing maintainable.

**Layer 4: The Proxy.** If the inspection engine clears a request, this layer forwards it to your actual backend and returns the response to the client. From the client's perspective, nothing unusual happened. They talked to your app. In reality their request went through a full inspection pipeline first.

**Layer 5: Logging and Observability.** Every blocked request, every passed one, every rule that fired gets logged. This is how you debug why a legitimate user got a 403 (it will happen) and how you build a picture of what kind of traffic you are actually seeing.

### Tracing One Request Through the Whole Thing

A malicious actor sends this to your server:

```sql
GET /users?id=1 OR 1=1--  HTTP/1.1
Host: yourapp.com
User-Agent: Mozilla/5.0
```

The `id=1 OR 1=1--` in the query string is a textbook SQL injection attempt. If your app is not using parameterized queries and this reaches it, your users table just got exposed to someone who had time to read one OWASP article.

With the firewall in place: the TCP listener accepts the connection, the parser constructs a structured request object, the inspection engine runs the query string through the SQLi detection rule, the rule fires, and the firewall responds 403 Forbidden before the backend sees anything.

The whole thing takes under a millisecond. The attacker gets a door slammed in their face and no useful information about why.

### The Dependency List

Here is the full `Cargo.toml` for the project. Nothing here needs to make sense yet. Each dependency gets introduced properly when we actually need it.

```
[package]
name = "rust-firewall"
version = "0.1.0"
edition = "2021"
[dependencies]
tokio = { version = "1", features = ["full"] }
httparse = "1.9"
hyper = { version = "1", features = ["full"] }
hyper-util = { version = "0.1", features = ["full"] }
bytes = "1"
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
regex = "1"
tokio-util = { version = "0.7", features = ["codec"] }
anyhow = "1"
thiserror = "1"
```

Hyper handles the proxy layer (forwarding requests upstream). Tokio is the async runtime. `tracing` gives us structured JSON logs. `regex` powers pattern matching in the rule engine, with important performance caveats covered in Part 3.

### Project Structure

```bash
rust-firewall/
├── src/
│   ├── main.rs              # Entry point, ties everything together
│   ├── listener.rs          # TCP listener and connection management
│   ├── parser/
│   │   ├── mod.rs
│   │   ├── request.rs       # HTTP request parsing
│   │   └── response.rs      # HTTP response construction
│   ├── engine/
│   │   ├── mod.rs
│   │   ├── rules.rs         # Rule definitions and evaluation
│   │   ├── context.rs       # Request context passed through the pipeline
│   │   └── verdict.rs       # Allow / Block / Challenge decision type
│   ├── detectors/
│   │   ├── mod.rs
│   │   ├── sqli.rs          # SQL injection detection
│   │   ├── xss.rs           # Cross-site scripting detection
│   │   ├── ratelimit.rs     # Rate limiting
│   │   └── ip_filter.rs     # IP-based access control
│   ├── proxy.rs             # Upstream forwarding logic
│   └── logger.rs            # Structured logging and audit trail
├── config/
│   └── rules.json           # Rule definitions in JSON
├── tests/
│   ├── integration/
│   └── fixtures/            # Sample malicious payloads for testing
└── Cargo.toml
```

Every file here gets built across this series. You will understand each one because we will write them together, not copy-paste them from somewhere and hope for the best.

### Why Rust

Firewalls sit on the hot path of every single request your application receives. A slow firewall is a slow application. A firewall with memory safety bugs is a security vulnerability inside your security software, which is an embarrassing way to have a bad day.

Rust addresses all three concerns in a way that other languages do not. On performance: Rust compiles to native code with zero-cost abstractions. Tokio's async model handles tens of thousands of concurrent connections without a garbage collector periodically pausing everything. On memory safety: the borrow checker makes use-after-free bugs impossible in safe Rust at compile time.

For security code, this is not a nice-to-have, it is a correctness requirement. And on correctness: Rust's type system is expressive enough that illegal states can be made unrepresentable. We will design the rule engine so a misconfigured rule cannot compile, let alone reach production.

This is why Cloudflare, AWS, and Discord have been moving performance-critical infrastructure to Rust over the last few years. It is engineering discipline built into the language.

### What is Coming Next

**Part 2** builds the TCP listener and the HTTP parser. By the end you have a server that accepts connections and prints parsed requests to your terminal.

**Part 3** builds the rule engine. Rules become first-class data structures. The `Verdict` type is born.

**Part 4** builds the attack detectors: SQL injection, XSS, rate limiting, all with proper pre-compiled regex so the performance does not collapse under load.

**Part 5** wires up the proxy layer, adds production JSON logging, writes integration tests, and covers deployment.

### Before Part 2

Install Rust via rustup, scaffold the project with `cargo new rust-firewall`, add the dependencies above to `Cargo.toml`, and run `cargo build` to confirm everything resolves cleanly. No code to write yet. Part 2 is where the actual work starts.

I did not understand how satellite imagery pipelines worked until I built one under pressure for ISRO scientists who needed it to work on demo day. I did not understand Rust's ownership model until I tried to build Ferrmail and the compiler rejected my mental model roughly twelve times before it accepted my actual model.

There is no shortcut here. Read this series, build the code, fight with the borrow checker. The mental model you end up with will be worth more than any certification course on network security.

*Souradip Pal is a Founding Engineer at CannerAI, final-year B.Tech CSE, and contributor to rust-clippy and rust-analyzer. He is building Ferrmail (a Rust email delivery platform) and ferroqueue (an embedded job queue). Find him at* *[souradip.me](https://souradip.me/)* *or* *[@soura\_dip\_pal](https://x.com/souradip3000)* *on X.*

[< Go to the original](https://levelup.gitconnected.com/the-untold-architecture-behind-production-firewalls-build-your-own-safeline-in-rust-from-zero-afc25c5c0cd6#bypass)