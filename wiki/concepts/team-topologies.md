---
title: Team Topologies
type: concept
created: 2026-06-06
tags:
  - concept
  - org-design
  - engineering-management
  - system-design
---

# Team Topologies

Team Topologies (Skelton & Pais) is a model for designing team-of-teams organizations where structure follows flow. It treats teams as the fundamental delivery unit and uses constraints to accelerate value delivery. The model connects organizational structure directly to software architecture outcomes.

## Conway's Law

"Any organization that designs a system will produce a design whose structure is a copy of the organization's communication structure." When architecture fights org structure, tensions appear. The Inverse Conway Maneuver deliberately alters team structure to encourage desired software architecture.

## Four Fundamental Team Topologies

**Stream-Aligned Team:** Aligned to a flow of work from a segment of the business domain. Full-stack, full-lifecycle — responsible for front-end, back-end, database, UX, testing, deployment, monitoring. No hand-offs to other teams for any purpose. The backbone of the organization.

**Enabling Team:** Helps stream-aligned teams overcome obstacles and detects missing capabilities. Temporary — builds skills in other teams, then moves on. Grows team capability rather than writing code for them.

**Complicated-Subsystem Team:** Handles components requiring significant mathematical/calculation/technical expertise that would overwhelm a stream-aligned team's cognitive load. Needed when the subsystem is complex enough that a dedicated team reduces overall organizational complexity.

**Platform Team:** Provides a compelling internal product that accelerates delivery by stream-aligned teams. Designed for self-service consumption. The key insight: the platform's primary benefit is reducing cognitive load on stream-aligned teams, not standardization or cost reduction.

## Three Interaction Modes

**Collaboration:** High-bandwidth, high-cost. Teams work closely together for a defined period. Best for discovering new APIs, practices, or technologies. Should be temporary.

**X-as-a-Service:** Low-cost, clear boundaries. One team provides, another consumes with minimal interaction. The default mode for mature platform relationships.

**Facilitation:** One team helps and mentors another. Temporary and focused. Used by enabling teams to build capability without creating dependency.

## Key Principles

- Focus on flow, not structure — structure only matters if value moves faster
- High trust is non-negotiable — low trust environments build wasteful processes
- Keep teams together — stable teams develop shared context that accelerates delivery
- Respect cognitive limits — each tool/responsibility taxes mental bandwidth
- Make changes small and safe — daily small improvements beat quarterly big releases
- Connect teams directly to customers — filtered customer needs slow everything down
- Eliminate team dependencies — handoffs between teams kill productivity

## Thinnest Viable Platform (TVP)

Most internal platforms become bloated. TVP provides just enough capability without unnecessary complexity. A good platform makes stream-aligned teams move faster, not generate more dependencies.

## Cognitive Load Management

The four-team topology model is a direct application of cognitive load limits to team design:

| Cognitive Load Type | Team Topology Mitigation |
|---|---|
| **Intrinsic** (domain complexity) | Stream-aligned teams own a bounded business domain. The team's intrinsic load is the complexity of its domain. |
| **Extraneous** (environment friction) | Platform team absorbs infrastructure, deployment, and observability complexity, reducing extraneous load on stream-aligned teams. |
| **Germane** (learning and improvement) | Enabling teams transfer skills so stream-aligned teams build capability without increasing permanent load. |

The rule: a team's total cognitive load should not exceed what the team can sustainably carry. If a stream-aligned team needs deep expertise in a complicated subsystem (video encoding, ML inference, financial calculations), split that subsystem into a dedicated complicated-subsystem team.

## Team Interaction Modes in Practice

The three interaction modes (Collaboration, X-as-a-Service, Facilitation) should be chosen explicitly based on the maturity of the interface:

- **Discovery phase** → Collaboration: two teams work together to define a new API, practice, or technology. Time-box this to avoid indefinite pairing.
- **Stable interface** → X-as-a-Service: once the contract is stable, the consuming team uses it with minimal interaction. The providing team owns evolution.
- **Capability building** → Facilitation: the enabling team helps the stream-aligned team learn a new skill. Ends when the stream-aligned team can operate independently.

Common mistake: staying in Collaboration mode too long after the interface is stable, creating an invisible dependency where both teams must coordinate for every change.

## Conway's Law in Reverse: The Inverse Conway Maneuver

The Inverse Conway Maneuver deliberately reorganizes team structure to produce a desired system architecture before building it. For example, if the target architecture is microservices with bounded contexts, reorganize teams to own those contexts. The architecture will follow the team boundaries.

Practical application for migration: before starting a monolith-to-microservices migration, organize teams around the target bounded contexts. Let the teams own their extraction. The resulting architecture will naturally reflect the team structure, which was designed to match the desired architecture.

## Links

- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/system-design|System Design]]
- Related: [[concepts/career-growth-meta-skills|Career Growth and Meta-Skills]]
- Related: [[concepts/microservices-architecture|Microservices Architecture]]
- Source: [[sources/team-topologies-org-design|Team Topologies: Engineering Organization Design]]
