---
title: "tech skills vs system design: Unlock case study in Production"
source: "https://dev.to/johalputt/tech-skills-vs-system-design-unlock-case-study-in-production-pb4"
author:
published: 2026-05-05
created: 2026-05-05
description: "Tech Skills vs System Design: Lessons from Unlock’s Production Journey   For years,... Tagged with tech, skills, system, design."
tags:
  - "clippings"
---
## Tech Skills vs System Design: Lessons from Unlock’s Production Journey

For years, engineering teams have debated the relative importance of deep technical skills and robust system design. The divide often pits coders who can ship features fast against architects who plan for scale, but real-world production outcomes prove this is a false dichotomy. This case study of Unlock, a consumer rewards platform, shows how balancing both drives sustainable production success.

## The False Dichotomy: Tech Skills vs System Design

Technical skills refer to hands-on proficiency in programming languages, frameworks, debugging tools, and domain-specific implementation. A engineer with strong tech skills can write efficient, bug-free code, optimize queries, and integrate third-party APIs quickly. System design, by contrast, focuses on high-level architecture: scalability, reliability, fault tolerance, data consistency, and tradeoff analysis for distributed systems.

The common pitfall is overindexing on one at the expense of the other. Teams that prioritize tech skills alone often build brittle systems that fail under load. Teams that overfocus on design without strong implementation skills ship late, buggy, or unmaintainable systems. Production-ready software requires both.

## Unlock’s Production Crisis: A Case Study

Unlock launched in 2022 as a rewards platform for e-commerce shoppers, letting users earn points for purchases and redeem them for discounts. The founding engineering team of 5 had exceptional tech skills: all were proficient in React, Node.js, and PostgreSQL, with track records of shipping features quickly at previous startups.

The initial MVP launched smoothly, hitting 10,000 signups in the first week with no performance issues. As the platform grew to 100,000 monthly active users, the team focused on adding new features: referral programs, brand partnerships, and personalized rewards. They rarely revisited architectural decisions, assuming their efficient code would handle growth.

The breaking point came during a flash sale with a major retail partner, which drove a 10x traffic spike in 15 minutes. The monolithic Node.js application, running on a single AWS EC2 instance with a single PostgreSQL database, crashed within 8 minutes of the sale start. No caching, no rate limiting, no circuit breakers, and no read replicas meant the database was overwhelmed by concurrent write operations. The outage lasted 45 minutes, costing Unlock $200,000 in lost partner revenue and churned 12% of active users.

Post-mortem analysis revealed the team’s tech skills had hidden systemic gaps: they could write fast endpoints, but had not designed for horizontal scaling, fault isolation, or traffic spikes. The crash was not a code bug, but a system design failure.

## Rebuilding with System Design First

Unlock’s leadership paused new feature development for 6 weeks to overhaul the system architecture, hiring a staff systems engineer to lead the effort. The team adopted a "design first, implement second" workflow:

- Broke the monolithic application into three microservices: User Service (React/Node.js), Rewards Service (Go), and Payment Service (Node.js), each with independent scaling.
- Added Redis caching for frequently accessed user and rewards data, reducing database read load by 70%.
- Migrated to managed Amazon RDS PostgreSQL with two read replicas, connection pooling, and automated backups.
- Implemented rate limiting (100 requests per minute per user), circuit breakers for third-party API calls, and graceful degradation (showing cached rewards data if the rewards service is down).
- Added full observability with Prometheus for metrics, Grafana for dashboards, and Jaeger for distributed tracing, plus chaos engineering game days to test failure scenarios.

The results were immediate: The next flash sale handled 50,000 concurrent users with zero downtime. Over the following 6 months, Unlock maintained 99.99% uptime, reduced average API latency by 40%, and cut infrastructure costs by 25% through efficient resource allocation. The team’s existing tech skills were critical to implementing these design changes quickly, but the system design framework made those skills effective at scale.

## Balancing Both: Actionable Takeaways

Unlock’s journey offers clear lessons for engineering teams:

- **Complementary, not competing:** Tech skills are the building blocks of implementation; system design is the blueprint. You cannot build a reliable production system with one without the other.
- **Stage-appropriate prioritization:** For MVPs, lean slightly more on tech skills to ship fast, but bake in basic design principles (modularity, no hard-coded configs, basic observability). For growth-stage products, prioritize system design audits and scalability work over net-new features.
- **Cross-skill intentionally:** Engineers should upskill in system design (read *Designing Data-Intensive Applications*, practice mock design interviews). System designers should keep tech skills sharp by participating in code reviews and occasional feature development.
- **Production-first mindset:** Always validate design assumptions under load, run chaos engineering experiments, and conduct blameless post-mortems for every incident to identify both skill and design gaps.

## Conclusion

Unlock’s production crisis and subsequent recovery prove that neither tech skills nor system design alone are sufficient for building reliable, scalable software. The best outcomes come from balancing both: using system design to guide implementation, and technical skills to execute that design reliably. For teams aiming to avoid costly production failures, the question is not "tech skills or system design?" but "how can we integrate both into every stage of our workflow?"