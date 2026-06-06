---
title: "SRE Incident Management: From Detection to Blameless Postmortem"
source: "https://incident.io/blog/sre-incident-postmortem-best-practices"
author:
  - "incident.io Engineering Team"
published: 2026-03-13
created: 2026-06-06
description: "A comprehensive guide to SRE incident management covering the five-phase incident lifecycle, Incident Command System roles, blameless postmortem culture, postmortem templates, automated timeline capture, and action item tracking discipline."
tags:
  - "clippings"
---

## SRE Incident Management: Blameless Postmortem Practices

### The Five-Phase Incident Lifecycle

1. **Detection:** SLO-based alerting, monitoring signals, user reports. Every page must be actionable.
2. **Triage:** Determine severity, assign IC, create communication channel, start timeline.
3. **Mitigation:** Restore service first (rollback, traffic drain, feature flag). Never conflate mitigation with root cause resolution.
4. **Resolution:** Deploy permanent fix after mitigation is stable.
5. **Postmortem:** Written record with timeline, contributing factors, action items.

### Incident Command System

Adapted from US wildland firefighting (1970s). Core invariant:

- **Incident Commander (IC):** coordinates but does NOT fix. Delegates all repair actions.
- **Scribe:** documents timeline, decisions, actions in real time.
- **Subject Matter Expert (SME):** investigates and fixes.
- **Communications Lead:** manages internal and external status updates.
- **Status cadence:** every 15-30 minutes during SEV-1. Fixed structure: what's broken, what we're doing, when next update.

**Self-host dependency trap:** Do not store incident documents or tools behind the service being fixed — maintain out-of-band access paths.

### On-Call Engineering

- **Rotation structure:** Primary handles pages, secondary escalates in 5 min. Follow-the-sun requires 6+ engineers per site; single-site 24/7 requires 8+.
- **Pager budget:** Google SRE caps at 2 distinct incidents per 12-hour shift. Above that, response quality degrades.
- **Alert hygiene:** Every page must be actionable. If no runbook exists, the alert should not page. Review paging rules quarterly.

### Blameless Postmortem Culture

Blameless does not mean no consequences. It means assuming everyone acted on the best available information at the time. The shift: from "who broke it" to "what system condition allowed this."

| Blame-oriented | Blameless |
|---------------|-----------|
| "Engineer deployed a buggy change" | "CI/CD pipeline did not catch the bug" |
| "On-call was slow to respond" | "Alert noise caused fatigue" |
| "Team missed a warning sign" | "Warning signs not documented in runbooks" |

### Postmortem Template

1. **Summary:** 2-3 sentences on what broke, when, for how long, impact.
2. **Impact:** users affected, duration, SLO budget consumed, revenue if applicable.
3. **Timeline:** UTC-timestamped events from first alert to full resolution.
4. **Contributing factors:** 2-5 systemic causes. Prefer "contributing factors" over singular "root cause." Use 5 Whys to surface them.
5. **What went well:** reinforce effective response behaviors.
6. **Action items:** each with named owner, priority, due date. Separate mitigative (fixes immediate gap) from preventative (prevents class of failure).

### Action Item Discipline

- Specific: "Add rate limiting to /search at 100 req/s" not "improve rate limiting."
- Owned: one named person, not "the team."
- Due-dated: specific date, not "soon."
- Track completion rate: below 50% means postmortems are theater. Target 80%+.

### Measuring Postmortem Effectiveness

- **Action item completion rate:** target 80%+
- **Incident recurrence rate:** below 5% is excellent, above 30% means learning loop is broken
- **Postmortem completion time:** target under 48 hours from resolution

### Common Failure Patterns

- Alert fatigue (track pager load per shift)
- Root-cause myopia (single factor — enumerate 2-5 contributing factors)
- Action items without owners or due dates
- Conflating mitigation with resolution
- Starting postmortem review with a blank document (draft before the meeting)
