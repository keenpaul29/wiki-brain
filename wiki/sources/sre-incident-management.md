---
title: "SRE Incident Management"
type: source
created: 2026-06-06
source: https://incident.io/blog/sre-incident-postmortem-best-practices
author: "incident.io Engineering Team"
tags:
  - source
  - sre
  - incident-management
  - reliability
  - operations
---

# SRE Incident Management

## Summary

A guide to the incident lifecycle (detection→triage→mitigation→resolution→postmortem), Incident Command System roles (IC, Scribe, SME, Comms Lead), on-call engineering practices (rotation structure, pager budget, alert hygiene), blameless postmortem culture, postmortem template, action item discipline, and measurement of postmortem effectiveness.

## Key Ideas

- Five-phase lifecycle: Detection (SLO-based alerting), Triage (severity, IC, comms channel), Mitigation (rollback/traffic drain, never conflate with root cause), Resolution (permanent fix), Postmortem (timeline, contributing factors, action items).
- Incident Command System: IC coordinates but does not fix; Scribe documents; SME investigates; Comms Lead manages updates. Status cadence: every 15-30 min during SEV-1.
- On-call: primary handles pages, secondary escalates in 5 min. Pager budget cap: 2 incidents per 12-hour shift.
- Blameless postmortem: from "who broke it" to "what system condition allowed this." Contributing factors (2-5) over singular root cause.
- Action item discipline: specific, owned by one person, due-dated. Track completion rate (target 80%+).
- Failure patterns: alert fatigue, root-cause myopia, action items without owners, conflating mitigation with resolution, blank-document postmortem starts.

## Links

- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/system-design|System Design]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
