---
title: "Stop Using the Wrong LLM | by Jose Crespo, PhD | in AI Advances"
source: "https://freedium-mirror.cfd/https://ai.gopubby.com/stop-using-the-wrong-llm-6980f3c8958e"
author:
published:
created: 2026-05-05
description: "Do you want to use AI productively? There are only three cognitive lanes that matter and eight..."
tags:
  - "clippings"
---
[< Go to the original](https://ai.gopubby.com/stop-using-the-wrong-llm-6980f3c8958e#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/1*iKKYSFh_eYTwoiLSZHiJ4g.gif)

## Stop Using the Wrong LLM

## Do you want to use AI productively?
There are only three cognitive lanes that matter and eight forbidden zones you must not enter.

### Oh no, another LLM guide?

I can understand that reaction. By now, everyone has seen too many of them, and you probably expect to find here another crowded table, another pointless ranking propped up by whichever benchmark fits the headline.

No. Forget it. Here you will not see another childish contest pretending to decide which LLM is the smartest, which is the cheapest, which writes the best code, or which sounds the most human. Most of that is BS when it comes to the thing that really matters to you: getting the damn job done in the best possible way.

So yes, you are lucky. Your frustration is welcome here, and what you are about to read is the first cognitive map of the frontier, the one built from your real work rather than from leaderboards.

### The Cards on the Table

Pay attention now, please, because this is where we are saying bye-bye to the non-scientific LLM classifications you see most of the time.

First, mathematics separates the chaff from the grain. Then the real work begins: I take 24 related LLM skill variables extracted in turn from hundreds of cases in professional environments with LLMs (the details of this first varimax are not shown here), run the rotation, and extract the three cognitive factors that actually predict which LLM is best suited to the task you need to solve. The animation below shows what came out.

![Watch 24 LLM skills collapse into 3 cognitive factors. What you are seeing is the math doing its work. The varimax rotation turns the three axes through the cloud until each one lines up with a natural direction already present in the data, while the cloud itself stays fixed. As that happens, the messy bundle of LLM skills, verbal ability, reasoning, mathematics, and the rest, condenses into three explanatory cogntive factors or lanes that account for nearly 63% of the variance in the full set](https://miro.medium.com/v2/resize:fit:700/1*R72TwTLvPRGAc3asGQGgrg.gif)

**Watch 24 LLM skills collapse into 3 cognitive factors.** What you are seeing is the math doing its work. The varimax rotation turns the three axes through the cloud until each one lines up with a natural direction already present in the data, while the cloud itself stays fixed. As that happens, the messy bundle of LLM skills, verbal ability, reasoning, mathematics, and the rest, condenses into three explanatory cogntive factors or lanes that account for nearly 63% of the variance in the full set of variables..

The method is math-legit. [Varimax rotation](https://www.cambridge.org/core/journals/psychometrika/article/abs/varimax-criterion-for-analytic-rotation-in-factor-analysis/88F99AA31F472BF854B01B6B92F4212B), the same basis-selection logic physicists use to find the principal axes of a tensor, the workhorse of factor analysis for nearly seventy years and [recently re-validated in the Journal of the Royal Statistical Society](https://doi.org/10.1093/jrsssb/qkad029). I scored twenty-four documented professional tasks on twelve cognitive primitives. Twenty-four cases, twelve dimensions, one matrix. I ran the rotation, and the math showed me the structure. That is what the animation shows.

I went looking for what was actually breaking on professional desks. Not second sources or unchecked claims. Just real failures, filed in the last months and weeks, by real teams shipping real work, sourced from [enterprise surveys](https://deepsense.ai/blog/inside-the-minds-of-ctos-why-we-built-an-enterprise-llm-adoption-report-for-2025-26/), [GitHub issues](https://www.datadoghq.com/state-of-ai-engineering/), [vendor documentation](https://contextqa.com/blog/llm-testing-tools-frameworks-2026/), and [trade-press post-mortems](https://www.artificialintelligence-news.com/news/generative-ai-trends-2025-llms-data-scaling-enterprise-adoption/). Hundreds of cases in total, every one of them a failed deployment that cost more than it was worth.

For each case I asked the same question: what LLM operation was the model failing to perform? Not which model, not which version, not which prompt. Just which underlying ability had broken down.

The list of abilities that explained those hundreds of professional cases is diverse. Some of the ones that came up most often: *reading long documents*, *synthesizing across many sources at once*, *holding a difficult interpretation in mind without collapsing it into the easy one*, *modeling the emotional state of another person*, *verifying its own output before reporting back*, *planning a long sequence of steps and recovering from a bad call halfway through*, plus a handful more related to other cognitively relevant operations.Twenty-four cognitive primitives in total, each case scored against each, the scores fed into the standard statistical tool that finds hidden structure in messy data, and then I waited to see what would come out.

### The Winners Take It All

Three independent dimensions came out. Three. That is the whole reason you have been wasting hours on the wrong model: every LLM is architecturally tuned for one of these three lanes, your professional task always pulls toward one of them too, and when the two do not match you pay for it in headaches and bills. Each lane absorbs a clean fraction of the documented professional pain, and every one of the hundreds of cases lands cleanly inside one of the three.

![The three cognitive lanes](https://miro.medium.com/v2/resize:fit:700/1*pFj6lLwmQNlfkOU5tK0UZQ.png)

Together the three explain **almost 63%** of all the cognitive demand the documented cases put on these models. **The remaining 37% is the residual** variance, the part the three lanes do not absorb.

**This residual factor is pointing to an empirical problem we have been checking for years in LLMs**: visual extraction tasks cluster on one end, text-native interpretation tasks cluster on the other. No current LLM crosses this divide reliably, regardless of which lab built it.

The pattern is consistent with [what some of us have argued for years](https://medium.com/ai-advances/its-the-geometry-stupid-how-isomorphic-labs-is-changing-the-whole-ai-industry-e8aa1afcf891), that flat-Euclidean architecture cannot stably represent objects with intrinsic structure, and visual artifacts (*charts with implicit axes*, *diagrams with directional arrows*, *multi-column layouts with reading order*) are exactly the objects that punish flat representation. The factor analysis points to the wound. The geometric analysis we have developed in previous articles explains it.

### LLMs Can Ruin Your Job and Reputation

The first practical conclusion is simple. Before you can use LLMs well, you need to know exactly where they fail, and where the failures are bad enough to endanger your job and your reputation.

> You may have heard the AI optimists and CEOs claim that all these problems will be solved eventually by throwing more computation and shinier GPUs at them. That is mathematically false. No matter how much computation you throw at it, the underlying geometry does not change, and the failures below will keep showing up exactly where they show up today.

Here is the black list of hard problems for current AI that those triumphant CEOs do not want you to see:

- **[Charts with implicit axes](https://arxiv.org/abs/2505.13444)****.** Extracting numerical values when the axes are unlabeled, the units live in a corner caption, and the data points carry no annotation, every available model guesses within plus or minus thirty percent at best.
- **[Multi-column scanned PDFs](https://arxiv.org/abs/2603.08655)****.** Reading order is encoded in the page layout, not in the token sequence, so the columns get read as if they were one long line.
- **[Diagrams with directional arrows](https://arxiv.org/abs/2505.07864)****.** Causation and temporal flow are erased the moment the geometry of the diagram is flattened, because flat-Euclidean attention does not carry directionality. ([TechING](https://arxiv.org/abs/2601.18238) confirms the same weakness on hand-drawn technical diagrams.)
- **[Long reasoning that closes back on itself](https://arxiv.org/abs/2504.12845)****.** Formal proofs, regulatory analyses where one rule references another that references the first, multi-step legal arguments that have to remain consistent across thirty pages, all break at the holonomy step.
- **[Tracking many entities across long context](https://arxiv.org/abs/2504.12845)****.** Forty named characters across a hundred-page novel reliably get confused with each other in every model in production today.
- **[Reliable counting in images](https://arxiv.org/abs/2504.15485)****.** Object counts past about six in cluttered photographs come back wrong across the entire current generation of LLMs.
- **[Admitting ignorance](https://openai.com/index/why-language-models-hallucinate/)****.** Saying *I do not know* instead of behaving like a charlatan remains the single most consistent failure across every lab and every benchmark.
- **[Tight precision on long-tail facts](https://openai.com/index/why-language-models-hallucinate/)****.** Specific dates, specific quantities, specific minor entities, the model will hallucinate before admitting it does not have the answer.
![Watch 24 LLM skills collapse into 3 cognitive factors. What you are seeing is the math doing its work. The varimax rotation turns the three axes through the cloud until each one lines up with a natural direction already present in the data, while the cloud itself stays fixed. As that happens, the messy bundle of LLM skills, verbal ability, reasoning, mathematics, and the rest, condenses into three explanatory cogntive factors or lanes that account for nearly 63% of the variance in the full set](https://miro.medium.com/v2/resize:fit:700/1*7awRugrlF8VmMTfM801pxg.png)

**The Easiest Way to Ruin Your Job Within Minutes** Send any of these tasks straight to your favorite LLM, accept the answer that comes back, and ship it. That is the recipe. Before you prompt, before you wire up a tool, before you stake your name on an AI-powered deliverable, know exactly where the model is going to fail you. The list above is the empirical boundary of competence, drawn by people who tested these systems at scale, and it is the line you cannot cross without paying for it.

### LLMs Can Save Your Job and give you Reputation

Now you enter the promising land of AI. Once you have avoided the forbidden territory explained above, you can increase your productivity dramatically, but only if you know which LLM instrument you are playing and what kind of music it is built to make. The three cognitive lanes are exactly that: three different registers, each tuned to play a different kind of professional work, each built by a different lab for reasons that are architectural and not accidental. Asking the wrong instrument to play the wrong piece is what produced the disasters above. Asking the right instrument to play the right piece is what produces the productivity gains the industry has been promising you for two years and mostly failing to deliver, because the industry keeps selling you one instrument and calling it an orchestra.

With this in mind we are in the condition to make a natural rank of the available LLM according to how their performance is in every of those 3 cognitive relevante lanes for getting the job done.

### The First Cognitive Classification of Frontier LLMs

Now we are getting somewhere. What you are reading now is not another benchmark leaderboard, and I want that to land before anything else, because it is the whole reason the animation below looks the way it does.

This is something the field has lacked until now: a cognitive map of the frontier, with three factors emerging from the mathematics of professional work itself — as shown in the previous sections — rather than being assembled from marketing decks or vendor launch tables.

Those three dimensions or cognitive lanes, applied to the different available LLMs, tell you which model to select for those demanding tasks or problems that previously required a sizable amount of checking and rechecking.

The model that dominates one lane is rarely the model that dominates the others, not because the labs are uneven, but because the cognitive demands themselves pull in different directions, and a single architecture cannot face all three at once. This is the geometry that the LLM ranks you have seen until now have been hiding.

![The first cognitive tour-de-force ranking of LLMs. Information integration, structural abstraction, and procedural execution are the three cognitive lanes explained above. Together, they let you see which LLM is strongest for the kind of problem you actually need to solve.](https://miro.medium.com/v2/resize:fit:700/1*ZSMq7-y0uskm2RxT4uH84g.gif)

**The first cognitive tour-de-force ranking of LLMs.** Information integration, structural abstraction, and procedural execution are the three cognitive lanes explained above. Together, they let you see which LLM is strongest for the kind of problem you actually need to solve.

### How to deal with your problems: LLM single approach \*

The map is one thing. Knowing which instrument to use for the task on your screen right now is the next step, and it is more deterministic than the erratic anecdotal advice from other LLM rankings might lead you to believe.

The animation below walks through the calculation that turns any single professional task into a clean lane assignment and reveals, in the same breath, how many minutes of your week you have been quietly bleeding by sending the wrong work to the wrong model for **realistic-size professional problems** like the ones we sampled for this article.

![The tax you pay for picking the wrong tool. There is a number the productivity-AI industry quietly hopes you never calculate, and this animationcalculates it for you. It takes six common professional tasks, each sitting clearly in one of the three lanes, and shows the minutes you save when you use the lane-primary model versus the minutes you waste when you just use whatever tool is already open in your browser. Behind each panel is the same formula: it converts published benchmark performance](https://miro.medium.com/v2/resize:fit:700/1*NyrX8bsC1ZVgVMX9fKOhxw.gif)

**The tax you pay for picking the wrong tool.** There is a number the productivity-AI industry quietly hopes you never calculate, and this animationcalculates it for you. It takes six common professional tasks, each sitting clearly in one of the three lanes, and shows the minutes you save when you use the lane-primary model versus the minutes you waste when you just use whatever tool is already open in your browser. Behind each panel is the same formula: it converts published benchmark performance into the extra checking and re-checking rounds you end up doing before you trust the answer enough to send it. Pick the wrong tool, and the cost is real: about 1.1 to 3.1 times more time, again and again, across task after task. That is the hidden tax the industry hopes you do not notice.

### How to Deal With More Complex Problems: The LLM Agentic Approach

The hard truth nobody told you about the wild west of AI is that one gun.. er…sorry one instrument, is rarely enough for the work that actually matters.

Compound or agentic work, by definition, is what happens when your problem is really a collection of smaller problems, each with different kinds of tasks.

The animation below shows what happens when each step is routed to the lane built for it on the scaled, realistic problems that actually fill your week. The gain is large enough that no single-model setup can match it.

![How to save yourself after you crossed the line. Suppose you ignored the warning. You sent the wrong task to the wrong model, and now the deadline is closer than any clean recovery. Welcome back. The problem was never one task. It was a chain of steps with different cognitive demands. Forcing the whole chain through one favorite model is what created the mess. The GIF above shows the fix: route each step to the lane built for it. Across the examples, this gives roughly a 2.3 to 2.5 times time a](https://miro.medium.com/v2/resize:fit:700/1*Kr6_-tX6QtNzsDj_69FZMA.gif)

**How to save yourself after you crossed the line.** Suppose you ignored the warning. You sent the wrong task to the wrong model, and now the deadline is closer than any clean recovery. Welcome back. The problem was never one task. It was a chain of steps with different cognitive demands. Forcing the whole chain through one favorite model is what created the mess. The GIF above shows the fix: route each step to the lane built for it. Across the examples, this gives roughly a 2.3 to 2.5 times time advantage on compound work. Not because one model suddenly became smarter, but because the right tool finally gets the right step.

### Summing up…

Stop trying to find the best LLM. Start asking which cognitive lane your task needs, then pick the model that owns that lane, and then add a second agentic model only when the work crosses lane boundaries. That is the entire framework.

> \*Note: How The Minutes Were Calculated

> **Single-task approach animation.** The big numbers in each panel are not benchmark scores, they are the minutes it takes you to trust the answer enough to send it. The conversion is a single formula: if a tool gets the task right with probability p on each attempt, then to reach 95% confidence the answer is correct you need log(0.05) / log(1−p) independent re-check rounds. A re-check round is one full pass of read the output, sanity-test it, decide whether to re-prompt, and that takes about 5 minutes per round in practice. Multiply rounds by 5 minutes and you get the minutes you actually feel at your desk. The per-task probabilities come from the published benchmark scores of each lab, [MRCR v2](https://arxiv.org/abs/2409.12640) for long-context retrieval, [SWE-bench Pro](https://arxiv.org/abs/2509.16941) for code review, [Terminal-Bench 2.0](https://arxiv.org/abs/2601.11868) for execution work, with the rest labelled illustrative on the GIF when no exact benchmark applies.

> **Agentic approch animation.** Same formula, applied step by step along a chain of tasks instead of to a single task. Each step in a compound workflow gets routed to its lane primary, runs its own re-check loop, and the total minutes are the sum across all the steps. The single-app totals (60, 90, 70, 45, 75 minutes) are the same chain forced through one tool that is weak on most of the steps, calibrated against publicly reported time savings from professionals who tracked the difference. The 2.3 to 2.5 times time advantage is the ratio between the two columns, robust across all five compound problems, and that ratio is the central claim the animation defends.

[< Go to the original](https://ai.gopubby.com/stop-using-the-wrong-llm-6980f3c8958e#bypass)