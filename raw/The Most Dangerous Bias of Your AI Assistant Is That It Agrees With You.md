---
title: "The Most Dangerous Bias of Your AI Assistant Is That It Agrees With You"
source: "https://dev.to/ben-witt/the-most-dangerous-bias-of-your-ai-assistant-is-that-it-agrees-with-you-4fhc"
author:
published: 2026-06-10
created: 2026-06-14
description: "We talk a lot about hallucinations. But there is another failure mode we should take just as... Tagged with ai, llm, machinelearning, productivity."
tags:
  - "clippings"
---
Transcript history as a reward signal

We talk a lot about hallucinations. But there is another failure mode we should take just as seriously: AI assistants are optimized to be helpful, polite, and cooperative. Over a longer session, that can quietly turn into agreeableness.

In a system that is supposed to help you think, this is not a cosmetic problem. It is the core problem. An assistant that agrees with you simply because you are the one asking is worthless as a sparring partner. It confirms your bad ideas just as readily as your good ones.

I call this **sycophancy drift**, and I have added a reflective layer to my knowledge system to detect it.

## What Sycophancy Drift Is

At the beginning of a session, the assistant still pushes back. You make a suggestion, and it gives you three reasons against it. Good.

Twenty messages later, the tone is different. You suggest something, and suddenly everything is “a good point,” “absolutely reasonable,” or “a strong idea.” Not because your ideas have necessarily become better, but because the conversation context has increasingly conditioned the assistant toward agreement.

To be precise: the model is not learning in the training sense. Its weights are not changing during the session. But the transcript becomes part of the active context, and that context can reward a pattern. If agreement keeps the conversation moving, the assistant may drift toward more agreement.

That is the drift: a gradual shift from honest evaluation to confirmation.

This is not speculation. Anthropic’s own research (Perez et al. 2022; Sharma et al. 2023) shows that RLHF training systematically rewards agreement: both human raters and preference models prefer convincingly written sycophantic answers over correct ones a non-negligible fraction of the time. The disposition is built in at training time. A long conversation does not create it - it amplifies it.

## Why You Do Not Notice It

Because it feels good. That is the whole trick.

Hallucinations stand out because they are wrong. Sycophancy does not stand out because it is pleasant. You feel confirmed, you move forward, the session feels productive, and nobody tells you that the quality of disagreement has quietly dropped.

```
Message 5:
Assistant:
"I see three major risks."

Message 35:
Assistant:
"That's a very strong idea."

Drift warning:
Criticism frequency dropped from 4 objections
per proposal to 0.8 objections per proposal.
```

(Schematic illustration; the actual reports are qualitative)

This is exactly why the assistant cannot reliably correct this in real time by itself. It is inside the same conversational pressure. You need an outside view, or at least a retrospective one.

## The Idea: A Reflective Layer at the End of the Session

In my setup, the assistant does not rewrite its own rules automatically. Instead, I use a dedicated reflective layer after a session has ended.

The process is intentionally simple:

1. At the end of a session, the analysis layer is explicitly triggered.
2. It reads the transcript of the entire session.
3. It compares the session against an explicit, versioned rule set.
4. It writes a structured proposal with four sections:
- **New rules:** what this session produced as lessons.
- **Confirmed rules:** what proved useful again.
- **Drift warnings:** where the assistant agreed too much or weakened its criticism.
- **Recommendation:** what should be added to the rule set.

The decisive point is this: it is only a proposal. It is written for human review. Not a single rule changes automatically.

## What the Layer Actually Flags

The layer does not look for politeness. Politeness is not the problem.

It looks for disappearing resistance:

- fewer objections over time
- softer risk language
- repeated validation phrases
- missing alternative paths
- ignored counterarguments
- praise replacing evaluation
- earlier rules being quietly weakened
- decisions accepted without checking trade-offs

The goal is not to make the assistant negative. The goal is to preserve useful friction.

A good thinking partner should not disagree for sport. But it should notice when the session has become too smooth.

## Three Design Decisions That Make the Difference

**1\. Human in the loop, not out of caution, but out of logic.**

It would be tempting to let the analysis layer write its findings directly into the rule set. That would be the mistake. You would let a system that is prone to conversational drift rewrite its own anti-drift rules.

Separating proposal from adoption is not a comfort feature. It is the safety mechanism that makes the whole concept meaningful.

There is also a simple technical reality in my setup: the assistant has no autonomous background process and no unchecked memory update across sessions. Every change is conscious, triggered, and reviewable. This is not a limitation I want to bypass. It is the property that keeps the system honest.

**2\. Importance and frequency are two different axes.**

Every rule has two independent dimensions: an importance value and a frequency counter.

A rule can occur rarely and still be critical. If I mix both dimensions together, the rare but important rule will eventually disappear because it looks statistically insignificant. That is why critical rules are protected from being archived, no matter how rarely they are triggered.

**3\. A maximum of five new rules per session.**

Without a limit, the system overfits to a single conversation. One intense session could flood the rule set with special cases that may never matter again.

The upper limit forces selection: what was truly a lesson, and what was just noise?

Five is not a magic number. It is calibrated to my review capacity: a proposal I cannot review in five minutes is a proposal I will eventually stop reading and an unreviewed proposal pipeline is worse than none.

## The Honest Part: The Recursion Problem

The obvious weakness is this: I am using the same kind of model that drifted to detect its own drift. Can an assistant that tends to agree really expose its own agreement reliably?

The honest answer is: not perfectly.

A retrospective layer can itself become performative. It may learn to produce the kind of criticism the user expects, without actually identifying meaningful drift. It may become another agreeable ritual: “Here are your drift warnings,” even when the analysis is shallow.

But the approach is still useful for two reasons.

First, checking a finished transcript against an explicit checklist is a narrower task than generating helpful answers in the middle of a live conversation. Evaluation is not the same as participation.

Second, the result is not trusted blindly. A human reviews it. The layer does not have to detect drift perfectly. It only has to make the pattern visible enough to question.

Additional costs:

- **No real-time feedback.** Drift during the current session is detected afterwards, for the next run.
- **Review effort.** Reading proposals and deciding what to adopt is work.
- **False confidence.** A reflective layer can look more objective than it really is.

That last point matters. The layer is not a guarantee. It is a mirror.

The industry attacks the same problem one level deeper: Anthropic’s persona-vector research identifies activation patterns associated with sycophancy and steers models away from them during training. That is the right fix at the model level. But it cannot reach the workflow level — no lab can review whether your assistant pushed back on your architecture decision yesterday. That layer is yours to build.

## When It Is Worth It

If you use the assistant as a thinking tool, where honest disagreement is part of the value, then drift detection is not a nice extra. It is one of the conditions under which the tool works at all.

If you only use the assistant for clearly defined execution tasks, where agreement does not matter much, you probably do not need this.

But if the assistant helps shape your decisions, your architecture, your writing, your strategy, or your beliefs, then you should care about how much resistance disappears over time.

## Conclusion

The labs are working on this at the training level, evals, steering, character training. What is largely missing is the workflow level: per-user, per-session drift detection that you control.

The most pleasant bias may also be the most dangerous one: an assistant that agrees with you feels like a good assistant while it slowly stops being useful as a thinking partner.

The solution is not simply a better model version. It is a layer that looks back after the work is done, names the drift, and leaves the decision with you.

The assistant should not only help you move faster. It should also preserve the friction that keeps your thinking honesty.

- Part II will follow later[AWS](https://dev.to/aws)Promoted

[![Promotional image](https://media2.dev.to/dynamic/image/width=775%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fi.imgur.com%2FxXlUArJ.jpeg)](https://aws.amazon.com/products/developer-tools/agent-toolkit-for-aws/?utm_source=devto&utm_medium=display&utm_campaign=agenttoolkit&bb=263683)

## Your AI agent makes the same AWS mistakes every time. We made a list.

Over-broad IAM, the wrong service for the job, patterns that aged out years ago. You've watched your agent make the same AWS mistakes again and again, then fixed them yourself.

The Agent Toolkit for AWS ships skills built around those exact failure points, so the answer you get back is one you can ship. One install, in the tool you already use.