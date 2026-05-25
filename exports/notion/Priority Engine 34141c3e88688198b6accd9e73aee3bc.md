# Priority Engine

## Scoring Model

Use a 1-5 scale for each field:

- `Impact`: How big the outcome is
- `Urgency`: How time-sensitive it is
- `Effort`: How hard it is (higher means harder)

## Formula

- Tasks: `0.45*Impact + 0.40*Urgency + 0.15*(6-Effort)`
- Projects: `0.50*Impact + 0.35*Urgency + 0.15*(6-Effort)`

## How to Use

1. Score all active tasks/projects weekly.
2. Work from highest `Priority Score` first.
3. Re-score when context changes.

## Heuristics

- Ship-fast work: high impact + low effort.
- Firefighting: high urgency gets temporary bump.
- Avoid low-impact high-effort work unless strategic.