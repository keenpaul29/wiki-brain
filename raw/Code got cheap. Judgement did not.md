---
title: "Code got cheap. Judgement did not."
source: "https://medium.com/@mattwhetton/code-got-cheap-judgement-did-not-91dad13c9ddc"
author:
  - "[[Matt Whetton]]"
published: 2026-05-19
created: 2026-05-26
description: "The dominant story about AI and engineering is that it lowers the bar. A junior with the right tooling can now do what a mid-level engineer"
tags:
  - "clippings"
---
![](https://miro.medium.com/v2/resize:fit:2000/format:webp/1*kKw0OJ9g4_oh5LmM__JCow.png)

Implementation has compressed. The layer above it has not.

The dominant story about AI and engineering is that it lowers the bar. A junior with the right tooling can now do what a mid-level engineer used to do. A mid-level can do what a senior used to do. The pyramid compresses, the org chart gets flatter, and the experienced engineers at the top become less essential because the leverage they used to provide is now baked into the tools.

I do not think this is what is happening. I think the opposite is happening, and the organisations betting on the first reading are going to feel it.

The bottleneck in an engineering team that uses AI seriously is no longer writing code. Implementation cost has been compressed faster than most teams have adjusted to. What is becoming scarce is the thing that decides what to implement, how it should fit together, and what to refuse. That work was always there. It used to be done in parallel with the implementation, often by the same people, often without anyone noticing it as a separate activity. Now that implementation has been partly automated, the judgement layer is standing on its own, and it turns out to be most of the job.

## What actually changed

For most of the last twenty years, the practical limit on what a small engineering team could ship was how much code its people could write, test, and maintain. That ceiling has moved. An engineer who is effective with AI tooling can now produce working implementations of things that would previously have taken a small team. The work still has to be specified, reviewed, and integrated, but the act of writing the code is no longer the rate-limiting step.

Most engineering organisations have noticed this, and most have reached for the same conclusion. If code is cheaper, you need fewer people to write it. The teams thin out at the top, where the people are most expensive, and the assumption is that AI plus a smaller group of less experienced engineers will close the gap. I wrote recently about how this changes [what a small team can actually reach](https://medium.com/@mattwhetton/the-two-person-team-is-the-new-ten-person-team-a579e353b802), and the same compression sits underneath the argument here.

That reading misses what code being cheap actually exposes. When implementation was expensive, the work of deciding what to build, what to leave alone, and what to refuse was hidden inside the work of building. It got done because senior engineers were already in the room, making those calls in the course of writing the thing. Now that the writing has been partly absorbed by the tools, the deciding hasn’t gone anywhere. It is still there. It is just no longer disguised as coding work.

## What judgement actually is

Judgement here is not a vague stand-in for experience. It is a specific set of things, and they show up daily.

It is choosing the right problem to work on, given that the team can now plausibly take on more than it should. It is making coherent trade-offs across decisions that are individually fine but collectively incoherent. It is holding the conceptual shape of the system steady when each new contribution wants to bend it slightly out of true. It is reading the operational consequences of a design that works on the happy path. It is saying no to complexity that has become cheap to add and therefore tempting to add.

None of these are new responsibilities. What is new is that they are no longer absorbed inside the implementation work. They have to be done deliberately, by someone who recognises them as the work.

## What this looks like in practice

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*9UjSvrEN-_gctXu68ldpSw.png)

The answer was plausible. It was also wrong in context.

We had a decision recently on one of the teams I run, about how to architect a new service for authorising payments. The service needed to respond quickly, and it needed to resolve atomically when something was authorised for a period of time. We worked through it with AI in the loop. The suggestions were sensible. Reasonable structure, reasonable boundaries, reasonable trade-offs. Then it reached for Redis as the caching and coordination layer.

## Get Matt Whetton’s stories in your inbox

Join Medium for free to get updates from this writer.

This is a good answer. In a textbook it might be the right answer. The problem is the answer it was good for was not the problem we actually had. We do not currently run a Redis cluster. We are not currently paying for one. Our infrastructure costs are very low and we had no pressure to expand that footprint. We needed something working quickly, and we had a database already running that was almost certainly fast enough for the operation we needed.

We pulled the design back to use the existing database. Not because Redis was wrong in principle. Because the call was not whether Redis would work; the call was whether we should pre-optimise into infrastructure we did not yet need, on a service whose actual load we did not yet know, when the existing tool was probably sufficient. That weighing was not in the AI’s suggestion. It was not going to be. The AI was reasoning about the problem in front of it. We were reasoning about the problem in front of it plus the company around it.

There is also a simpler failure mode worth naming briefly, because it tends to dominate the conversation and it is the easier one to catch. AI sometimes makes local mistakes. On a side project of mine, working on different views of the same data, the AI built two separate pages where one parameterised page would have been correct. The cost showed up later, every time I asked for a change and got it applied in one place and not the other. That kind of mistake is real, but it is the visible kind. You notice it, you fix it, you move on. Better tooling will probably reduce its frequency over time.

The Redis call is the harder kind. The answer was plausible. The answer would have shipped. The answer would have looked fine in review. It was wrong in context, and the only thing in the room that knew it was wrong in context was someone who had watched enough of these calls go the other way.

## What seniors are actually for now

The model that produced most current engineering hierarchies rewarded the people who could personally carry the most implementation load. The strongest senior was often the one who could ship the most, fix the hardest bugs, and hold the most of the system in their head while doing it. That version of seniority is being commoditised faster than most organisations are admitting.

The version that is becoming more valuable is different. It is the engineer who can direct a set of AI-assisted contributions and keep them coherent. The one who can hold the architecture steady across more change than was previously possible to absorb in the same time window. The one who can reason across ambiguity, name the operational risk that nobody has surfaced yet, and decline the plausible answer that is wrong in context. The work has shifted from producing every artefact to shaping the leverage that produces them.

This is not a soft skill argument. It is not about communication or stakeholder management, both of which matter but are not the point. It is about the technical judgement that decides what gets built and what does not, applied to a flow of work that used to be slow enough to self-regulate and is now fast enough that it does not.

## The mistake to avoid

The reflex right now is to read cheap implementation as a signal to reduce the senior end of the team. The logic is straightforward. If juniors with AI can produce more than they used to, you need fewer expensive people directing them.

This is the wrong call, and it is the call I think will define which engineering organisations struggle most over the next few years. Not the ones slow to adopt AI. The ones that adopted it, watched the implementation cost drop, and concluded that the judgement layer had dropped with it. It did not. It became more important, and more exposed, and more visible as a distinct activity. Removing the people who were doing it, on the theory that the tools now did it for them, is the move I would most actively bet against.

The teams that get the most out of AI will be the ones that keep their experienced engineers and change what those engineers do. Less personal production. More direction. More refusal of the plausible. More holding the system steady while it is being changed faster than it used to be.

## Where I land

Code is cheap now in a way it was not five years ago. That is real, and it changes the shape of engineering work. It does not change the shape in the direction most people are pricing in.

The bar has not been lowered. The work of writing has been compressed, and what has been exposed underneath is the work that always mattered most and was hardest to see. That work is more senior, not less. The teams that recognise this and structure for it will do well. The teams that do not will spend the next few years discovering, slowly and expensively, that the part of the job they removed was the part that was holding everything together.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*FgVcrTO0D7Urt74YNDjJNQ.png)

Less personal production. More direction.