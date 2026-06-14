---
title: Incident Management and SRE Practice
type: concept
created: 2026-06-14
tags:
  - concept
  - sre
  - incident-management
  - reliability
  - operations
---

# Incident Management and SRE Practice

Incident management is the operational discipline of detecting, triaging, mitigating, and learning from production failures. It is distinct from reliability engineering (preventing failures) and observability (detecting and diagnosing failures). Incident management handles what happens when failure occurs despite prevention and detection.

## Incident Lifecycle

```
Detection → Triage → Mitigation → Resolution → Postmortem
```

### Detection

Incidents should be detected by SLO-based alerts, not by user reports:

| Detection Method | Quality | Notes |
|-----------------|---------|-------|
| User reports | Poor | Users should not be your monitoring system |
| Threshold alert | Good | Simple, but generates noise |
| Burn-rate alert | Excellent | Catches fast error-budget consumption |
| Synthetic monitoring | Good | Catches issues real traffic misses |

**Goal**: detect within 1-2 minutes of the start of the incident.

### Triage

On alert, the on-call engineer assesses severity:

| Severity | Definition | Response | Examples |
|----------|-----------|----------|----------|
| SEV-1 | Service down or data loss | Immediate, wake up | All users get 503 |
| SEV-2 | Severe degradation | < 15 min | Latency > 5x normal, partial outage |
| SEV-3 | Minor degradation | < 1 hour | SLO breaching slowly, single-region |
| SEV-4 | Cosmetic or tech debt | Next business day | UI glitch, deprecation warning |

**Triage actions:**
1. Acknowledge the alert.
2. Determine severity (first guess, can be revised).
3. Declare incident if SEV-1 or SEV-2.
4. Open a communications channel (#incident Slack channel).
5. Appoint Incident Commander.

### Incident Command System

The ICS assigns clear roles to prevent confusion during incident response:

| Role | Responsibility |
|------|---------------|
| **Incident Commander (IC)** | Coordinates response, does not fix. Makes decisions about severity, resource allocation, and stakeholder communication. |
| **Scribe** | Documents the timeline: what was tried, when, results. The scribe does not fix either. |
| **SME (Subject Matter Expert)** | Investigates the technical issue: reads logs, checks dashboards, proposes and tests fixes. |
| **Comms Lead** | Manages external communication: status updates to stakeholders, customer-facing messaging, escalation notifications. |

**Status cadence**: the IC calls for status every 15-30 minutes during SEV-1. Each update covers:
- What we know now (facts, not theories)
- What we are doing (current investigation or mitigation)
- What we need (escalation, additional SMEs, tools access)

### Mitigation vs Resolution

**Mitigation** stops the bleeding. It gets users working again. This is the priority.

**Resolution** fixes the root cause. It prevents recurrence.

Never conflate the two. A rollback is mitigation (you are back to the known-good state). The bug causing the incident still needs a resolution.

| Mitigation | Resolution |
|------------|-----------|
| Rollback to previous version | Fix the bug in the new version |
| Traffic drain to healthy region | Fix the unhealthy region |
| Feature flag to disable the feature | Fix the feature |
| Scale up capacity | Fix the performance bug |

### Resolution

After mitigation, the SME and team investigate the root cause. The goal is not to find one "root cause" (singular) but the contributing factors (2-5) that allowed the incident to occur:

- The deployment that introduced the bug.
- The test that did not catch it.
- The monitoring that did not alert.
- The runbook that was outdated.
- The on-call engineer who was unfamiliar with the subsystem.

### Postmortem

A blameless postmortem focuses on system conditions, not human errors:

**Template:**
- Summary: one paragraph.
- Timeline: what happened, when (from detection through resolution).
- Contributing factors: 2-5 system conditions that enabled the incident.
- Impact: users affected, duration, error budget consumed.
- Action items: specific, owned by one person, due-dated, tracked to completion.
- Lessons learned: what worked, what did not.

**Rules:**
- No blame. Replace "who broke it" with "what system condition allowed this."
- Action items must be specific and owned by one person.
- Track action item completion rate. Target > 80%.
- Share the postmortel broadly. Every incident is a learning opportunity.

## On-Call Engineering

### Rotation Structure

| Team Size | Rotation Length | Best Practice |
|-----------|----------------|---------------|
| 3-5 people | 1 week primary | Simple, but intense |
| 6-10 people | 1 day primary | Spreads load, more context switches |
| 10+ people | 2-4 hour shifts | High coverage, frequent handoffs |

**Primary handles the page.** **Secondary** escalates if the primary does not acknowledge within 5 minutes.

### Pager Budget

Cap the number of incidents per shift. Two per 12-hour shift is a reasonable maximum. Exceeding the budget indicates systemic issues (alert fatigue, monitoring noise, fragile system).

### Alert Hygiene

| Alert Type | Behavior | Good or Bad? |
|------------|----------|-------------|
| Page for every error | High noise | Bad — alert fatigue |
| Page only when SLO breaches | Actionable | Good |
| Page for known maintenance | Noise | Bad — suppress during maintenance windows |
| Page that auto-resolves before acknowledgment | Waste | Bad — fix the threshold |
| Page with no runbook | Confusing | Bad — every alert needs a runbook |

### Handoff

On-call handoff should cover:
1. Open incidents and their status.
2. Recent changes or deployments.
3. Known issues or ongoing investigations.
4. Maintenance windows scheduled.
5. Runbook updates.

## SRE Metrics

### DORA Metrics

| Metric | Elite | High | Medium | Low |
|--------|-------|------|--------|-----|
| Deployment frequency | Multiple/day | Once/day | Once/week | Once/month |
| Lead time for changes | < 1 hour | < 1 day | < 1 week | < 1 month |
| Change failure rate | < 5% | < 10% | < 15% | > 15% |
| Time to restore (MTTR) | < 1 hour | < 1 day | < 1 week | < 1 month |

### Error Budget

Error budget = 100% - SLO target. For a 99.9% SLO, the budget is 0.1% of total requests (about 43 minutes of downtime per month).

- Spending the budget on releases: acceptable — the budget is there to be spent.
- Exhausting the budget: stop all releases until the budget recovers.
- Never spending the budget: SLO may be too loose, or teams are too risk-averse.

## Links

- Parent concept: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/observability-and-monitoring|Observability and Monitoring]]
- Related: [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]]
- Source: [[sources/sre-incident-management|SRE Incident Management]]
- Source: [[sources/observability-in-distributed-systems|Observability in Distributed Systems]]
- Source: [[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]]
