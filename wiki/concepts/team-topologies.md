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

## Links

- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/system-design|System Design]]
- Related: [[concepts/career-growth-meta-skills|Career Growth and Meta-Skills]]
- Source: [[sources/team-topologies-org-design|Team Topologies: Engineering Organization Design]]
