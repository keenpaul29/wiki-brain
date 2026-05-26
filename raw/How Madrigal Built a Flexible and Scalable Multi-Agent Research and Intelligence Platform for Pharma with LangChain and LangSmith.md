---
title: "How Madrigal Built a Flexible and Scalable Multi-Agent Research and Intelligence Platform for Pharma with LangChain and LangSmith"
source: "https://www.langchain.com/blog/customers-madrigal"
author:
  - "[[P. Patel]]"
  - "[[R. Filippo]]"
published: 2026-04-29
created: 2026-05-26
description: "See how Madrigal Pharmaceuticals built a modular, multi-agent research platform on LangChain and LangGraph. They deployed on LangSmith and went from prototype to enterprise deployment in weeks."
tags:
  - "clippings"
---
## Key Takeaways

- **Abstracting data sources is what makes multi-agent systems scale.** Madrigal normalized every data source into a consistent tool interface. Agents don't care where data came from; they just use it. That abstraction is what lets you add new domains without rewriting orchestration logic.
- **Modular skills turn a single use case into a platform.** Instead of hardcoding workflows, Madrigal built each capability as a swappable skill. When a new need emerged, they defined a new skill, not a new system. New use cases went from weeks of development to hours, and deployment complexity didn't grow with scope.
- **Observability is what closes the loop between prototype and production.** LangSmith tracing gave Madrigal visibility into every tool call, retrieved chunk, and agent decision. More importantly, production failures fed automatically back into their eval suite so the system learned from real errors, not synthetic test cases.

*This is a guest post by Parth Patel, Global Head of AI and Data Science @ Madrigal Pharmaceuticals and Ron Filippo, CIO @ Madrigal Pharmaceuticals.*

At Madrigal Pharmaceuticals, Inc. we didn’t set out to build an enterprise multi-agentic platform. *Most enterprise systems don't start as platforms. They start as a question.*

Ours began with a key question for a pharmaceutical company: *how do we integrate, search, and synthesize information from diverse datasets at scale*.

To do that, we’d have to build a workflow that pulls information from multiple sources, applies structured thinking, and produces trusted answers.

At first, it looked like a single use case. But it quickly became clear that we were building a more general agentic solution that knows how to solve many problems the same way. A system that can:

- search across sources
- reason over structured criteria
- synthesize outputs at scale, and
- operate autonomously

That idea became the foundation of our enterprise multi-agentic platform.

We wanted Madrigal employees to be able to easily search, analyze, and synthesize relevant data spread across our enterprise within appropriate access controls, while ensuring every response was clearly cited. The platform is designed with role-based permissions and data governance guardrails so users only access information they are authorized to use. Building trust in our multi-agentic platform frees Madrigal users to focus on our north star core value: keeping patients with MASH at the heart of everything we do.

## Breaking down data silos

Building a pharmaceutical-grade multi-agentic platform leaves no margin for error. We have to ensure the right data is analyzed correctly by the appropriate agent. However, like at any enterprise, information is scattered everywhere: structured systems, unstructured documents, external sources, real-time APIs... Each one useful but disconnected from the others.

We pieced together the disconnected data sources through a suite of parallelizable tool calls available to the multi-agentic platform. During this process, one of the biggest constraints in enterprise systems is that every data source behaves differently—different formats, different access patterns, and different expectations. We solved this by making the differences invisible to the agents. No matter where data comes from, it is normalized, stored in the same secure data warehouse, and made accessible through a consistent tool interface. From the agent's perspective, it's all just information it can use. That abstraction is what allows the system to operate across domains without rewriting logic each time.

## LangChain and LangGraph were the right place to build

The LangChain framework combined with the LangSmith Platform is more than a toolset for our team; it represents a platform philosophy that automates our process.

The full pipeline visibility, iterative development cycle, and monitoring gave us the community-driven innovation of open source, without sacrificing what enterprise-grade production systems demand.

The *developer experience* of the LangChain framework is integrated with common agentic patterns and capabilities (like deep agents, middleware, and skills), which means we're not building the agent framework, we're building Pharma intelligence on top of it.

All of this is natively integrated with deployment and scale; LangSmith deployment makes these agents immediately accessible across the company, which is a common bottleneck for small teams.

When we say *platform philosophy*, it’s how these elements come together to cover what we needed—from focus on domain-specific reasoning, to instant deployment, monitoring, and tracing. In particular:

- We needed a framework that could handle **multi-agent coordination at scale.**
- LangSmith provided **full traceable pipeline visibility behind** every action, decision, and step.
- The LangChain framework enabled **iterative development** with confidence; small changes yielded tangible results.
- LangSmith removed a whole category of common enterprise problems with **deployment and CI/CD workflows**, helping bridge the gap between prototypes to daily enterprise use *in weeks rather than months*. An unexpected benefit of LangSmith was **ready-to-deploy UI integrations** through well-defined API endpoints. LangSmith Observability enabled **real-world usage monitoring** identifying common use cases and friction points.

The LangChain team served as a **genuine thought partner** throughout the process ensuring a high-quality developer experience.

## From one system to many agents

Building a single system that can analyze diverse data and synthesize everything breaks quickly under complexity. Instead, we leaned into a different model: multiple agents working in concert, each doing one thing well, working towards an overarching major goal. Some agents search. Others analyze. Others synthesize. And sitting above them is an orchestrator deciding how the work to accurately analyze and synthesize diverse datasets gets done.

LangChain’s DeepAgents agentic harness allowed us to easily implement orchestration and parallel execution. The harness includes features such as a virtual filesystem, context management, modular skill capabilities, and checkpointing all out of the box. This lets us focus on building agents tailored with the Pharmaceutical industry in mind, not the mechanics of agent coordination.

The harness allows the system to divide and conquer. Instead of forcing intelligence into one place, you distribute it and then coordinate it... similar to how human brains work.

## The Role of the Orchestrator

The orchestrator is where intent meets execution. It receives a task and decides what needs to happen next:

- which capabilities are required
- which agents should run
- what should happen in parallel and when to bring everything back together.

It doesn't need to know the details of every domain. It just needs to know how to route the solutions to address the problem. That separation keeps the system flexible.

Research methods and requirements vary across the enterprise, so the orchestrator is built around a modular set of workflows that reflect those differences. As new use cases emerge, the system grows by adding a new workflow in the form of a *skill*, not by increasing the complexity of the orchestrator itself.

## Skills: the key to reusability

Once the system worked for one workflow, the next question came quickly: can it do something else?

Instead of hardcoding logic, we introduced modular capabilities based on Anthropic’s *skills* approach. Each skill defines how to approach a type of problem: what to look for, how to reason about it, what good output looks like. The orchestrator simply loads the right skill at the right time. That means adding a new use case doesn't require rebuilding the system. It just requires defining a new way of thinking.

![](https://cdn.prod.website-files.com/65c81e88c254bb0f97633a71/69f355041f7a1eae1778b75e_langsmith-architecture-dark%201.png)

## Why parallelism changes the game

One of the first things we realized is that most complex work doesn't need to happen sequentially. If a task involves exploring multiple angles, querying multiple sources, or analyzing different dimensions, there's no reason to do that one step at a time.

Multiple agents run in parallel, each focusing on a different slice of the problem. By the time the system comes back together, it combines fully formed pieces of work. The orchestration agent can divide a research question into three parts to three sub-agents, who can then parallelize the analysis of individual datasets within their own work. This increases accuracy and scope while decreasing latency.

## Observability and evals with LangSmith

The hardest part of building across multiple data sources isn't retrieval, it's knowing whether retrieval is working. When a response is wrong, is it because the data isn't in the index? the query didn't surface it? or the agent trusted a source it shouldn't have?

*Tracing* enabled real analysis of agentic behavior; the first time we saw traces for our system in Langsmith revealed how limited our visibility was before. We could only observe stimulus-response behavior, not the actual cognition. Tracing in LangSmith feels like going from basic psychology to neuroimaging for our agentic AI system; we were able to see what was actually happening inside the brain of our system.

We started with LangSmith's agent evaluation framework trace-level evals on full agent runs, using LLM-as-judge graders designed to mirror real end-user business feedback forms that score the outcome rather than the exact path. Every tool call, every retrieved chunk, every agent decision is visible and tagged by session ID. If tracing is neuroimaging for your agent system, LangSmith is the fMRI that shows you which regions activated, in what order, and whether the result made sense.

The part that's made the biggest ongoing difference: production failures feed back into our LangSmith datasets automatically. Every meaningful error becomes a new test case. The eval suite grows from real failures, not synthetic scenarios.

## Deploying with LangSmith

A small team building for enterprise use has real tension: you need reliability and scalability, but you don't have a large engineering team to run infrastructure.

LangSmith Deploy resolved that. We deployed our graph as a managed service with state persistence, concurrent sessions, and real-time streaming to the UI without rewriting core logic. Our CI/CD pipeline in GitHub triggers automatic redeployment, so skill updates ship without manual steps. The acceleration was a welcome surprise. Going from prototype to enterprise use took weeks, not the months we'd budgeted.

## Scaling across domain experts

Agentic skills allow us to open up the development to domain experts at Madrigal. Pharma experts know which evidence hierarchies matter, which databases to trust, and what good output looks like. That feedback loop is faster than anything we've built before; a user will notice something about the logic of the system, and the modularity of the deep agents’ harness allows us to easily address any shortcomings.

We are now working on rapidly scaling the platform to serve as many of Madrigal’s search, analysis, and research needs as possible. Because of how we built LangChain and LangGraph, the compounding effect is where the real value shows up. You see it

- when development for a new use case that would typically take weeks is reduced to hours
- when systems that required manual effort become self-sustaining
- when new use cases don't require new infrastructure
- (and most importantly) when subsequent deployments happen progressively faster.

That's when you know you're no longer isolating solutions. You're building on a system that enables you to build faster and better.

## The value of LangSmith extends beyond the platform

What makes LangSmith particularly valuable is how they operate. They have a rare ability to absorb the best thinking from the open-source community into the LangChain framework, while also staying deeply responsive to the realities of enterprise teams.

That continuous feedback loop, between developers in the field and enterprise customers using the platform, is exactly what AI development demands. LangChain takes that seriously, and it shows in their stellar enterprise support, their solicitation of platform feedback, and how consistently that feedback surfaces in their framework and platform as they evolve.

Beyond the technology, there's something equally important: we are clear on where they are headed. Their team is genuinely forward-thinking, with a clear pulse on where agentic AI is heading. That means we're not constantly looking over our shoulders, wondering if we're using the right tools or missing something better. That confidence frees us to focus on what actually matters, building a system that transforms our data into meaningful impact for MASH patients.

> *The ROI of agents really shows up when you can reuse the pattern and not just ship a single use case. LangSmith helps make that real for Madrigal with managed deployment, tracing, and evals all in one place, so every new agent starts on solid ground. That’s how our teams can build and launch enterprise-grade systems in weeks, not months, helping us move faster in the fight against MASH.  
> —Parth Patel, Global Head of AI and Data Science, Madrigal Pharmaceuticals*

> *At Madrigal, our technology goal is to 10X our productivity so we can impact patients' lives and lead the fight against MASH. LangSmith has been a critical partner in that journey as we grow scale AI across our operations. It gives us end-to-end visibility across the agent lifecycle, from development and evaluation to deployment and continuous improvement. That trust is a non-negotiable for the high-stakes environment of our AI systems.  
> —Ron Filippo, CIO, Madrigal Pharmaceuticals*

---

## About Madrigal Pharmaceuticals, Inc.

Madrigal Pharmaceuticals, Inc. (Nasdaq: MDGL) is a biopharmaceutical company focused on delivering novel therapeutics for metabolic dysfunction-associated steatohepatitis (MASH), a liver disease with high unmet medical need. Madrigal’s medication, Rezdiffra (resmetirom), is a once-daily, oral, liver-directed THR-β agonist designed to target key underlying causes of MASH. Rezdiffra was the first medication approved by both the FDA and European Commission for the treatment of MASH with moderate to advanced fibrosis (F2 to F3). An ongoing Phase 3 outcomes trial is evaluating Rezdiffra for the treatment of compensated MASH cirrhosis (F4c). For more information, visit [www.madrigalpharma.com](https://www.madrigalpharma.com/).