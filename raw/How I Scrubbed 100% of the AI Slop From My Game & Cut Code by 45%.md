---
title: "How I Scrubbed 100% of the AI Slop From My Game & Cut Code by 45%"
source: "https://medium.com/according-to-context/how-i-scrubbed-100-of-the-ai-slop-from-my-game-cut-code-by-45-1d1f99b564c1"
author:
  - "[[Dr. Derek Austin]]"
published: 2026-03-04
created: 2026-06-01
description:
tags:
  - "clippings"
---
## Just 3 weeks ago, I had 191,000 tokens in my upcoming tactical survival roguelite game’s codebase; today, I have 104,000 tokens: a reduction of 45%. More importantly, I scrubbed out 100% of the AI slop, and I know how to prevent it coming back. Here’s how I did it and what to know to keep LLMs from slopping your code.

![](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*yBY73dU_-9f1zq-tCBzUbA.png)

(AI-generated diagram prompted & upscaled by )

AI slop is a huge topic these days, especially for us SWEs who are realizing that technical debt seems to be increasing exponentially because of large language models — not just because our product managers won’t ever let us refactor the codebase to address the tech debt.

For the last 3 months, I’ve been using more than a million tokens (words) a day working with an LLM (Gemini 2.5 Pro, [now Gemini 3 Pro](https://archive.is/o/PUYt6/https://medium.com/according-to-context/gemini-3-first-impressions-benchmarks-including-deep-think-40a00a622e8d)) to build a tactical survival roguelite game in Godot using GDScript and C#.

Despite my best efforts, AI slop crept in in a way that will be familiar to most SWEs who have tried using LLMs to code.

When the project was “greenfield” (new) and the code was under 100,000 tokens total, there wasn’t a lot of AI slop. But given the phenomenon of [context rot](https://archive.is/o/PUYt6/https://www.youtube.com/watch?v=TUjQuC4ugak), where LLM performance degrades as context (the chat conversation length, in tokens) gets longer and longer, I had a ton of AI slop by the time I got to 191,000 tokens 3 weeks ago.

Now I’m back down to 104,000 tokens, and I have reviewed every line of every file of my codebase 3, 4, or 5 times, so that I am 100% sure there is no AI slop remaining. Here’s how I did it.

![](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*Gz-gg1ysTaF7D1efNKhMkw.jpeg)

Nigel Hoare for Unsplash+ (3D render, not AI-generated. Unsplash+ license; used with permission.)

## LLMs Write the Worst Comments I Have Ever Seen

It all started innocently enough with me instructing the LLM to write “architectural comments” explaining the “why” behind each file as I was generating it. At first, these comments worked great and were a nice way of understanding how the goal (feature, bug fix, refactor, etc.) I was working on was translating into the code, particularly for service relationships.

Unfortunately, even though I was super clear that only valuable, insightful, terse “why” comments were allowed, you can guess what happened next.

I knew I had a problem when I started reading comments like `A2Cb compliance: else on new line` that were simply me trying to get the LLM to write correct GDScript, where `else` statements have to be on new lines.

Thankfully, the solution here was easy: Search and Replace in Files.

In a matter of minutes, I had removed every single code comment, a total of about 40,000 tokens removed from the codebase.

Were there some useful code comments that I deleted? Yeah, surely. A couple of [the “why” code comments](https://archive.is/o/PUYt6/https://medium.com/career-programming/stop-documenting-what-and-start-documenting-why-you-made-your-code-decisions-in-your-comments-fc2117f74c3c) *were* useful, but <1% of them.

There were many more “marginally useful” comments, about 30%, describing flow or architecture but in a way that was just duplicating what the code itself was saying and thus weren’t of much use at all.

Finally, the amount of entirely useless code comments that were just explaining what the next line of code was doing (or worse) was ~70%.

![](https://miro.medium.com/v2/resize:fit:720/format:webp/1*pQljwWBYx5wZ7SGolySZCQ.png)

(AI-generated diagram prompted & upscaled by )

Obviously, [the only useful type of code comment](https://archive.is/o/PUYt6/https://medium.com/career-programming/why-some-devs-hate-code-comments-but-you-might-not-4e592a87c043) is something explaining why, such as: *this line needs to be exactly like this for this reason to prevent this type of bug from recurring.* After all, not *all* code comments are bad!

A great example of a useful comment in my game’s code is why I “work around” some of Godot’s input mapping (for controller, mouse, and keyboard inputs), apparently due to bugs in the Godot engine.

To be specific, left-click and right-click using the mouse aren’t being “caught” and “mapped” correctly by the Godot project settings’ input map, even though they *should* be. If I delete that comment, I’ll forget the bug!

## I Banned LLMs From Writing Code Comments

Since I couldn’t come up with a concept that the LLM could understand for that type of code comment being allowed, I found it was way better to just ban the LLM from ever writing code comments again.

To do so, I updated all of my style guides and context engineering documents to ban code comments of any kind written by the LLM.

In the end, other than the aforementioned “bug recurrence prevention” comments, I did have to make one other exception to my “no code comments” rule, which is that my game needs a deterministic startup (or load) order for its services because of the data flow in the app.

Since I didn’t want to pass around and duplicate a lot of data or state throughout the app, I preferred a single source of truth (canonical ownership of state data) in a centralized place. As a result, my app is really dependent on executing the first run code in a very specific order.

That ended up being the one other exception, which is answering the question of *why do I need to start up these services in exactly this order?*

After all, I consider that the most useful type of code comment, a code comment that prevents me from repeating a bug that I’ve already solved.

The trick, of course, is making sure that I write the comments myself, because LLMs simply do a terrible job, as with any LLM “writing.”

As I’m revising and refactoring the code, I try to make the code comments useful for things like future bug prevention and improving my mental model and understanding of the codebase.

If they’re not serving that purpose, then yeah, I do scrub them out.

LLMs *love* trying to write code comments anyway, especially as the chat goes more than 5–10 messages past my initial prompt.

Overwhelmingly, LLMs cannot write useful, professional documentation!

I recommend you never try to use LLMs to write documentation; it’ll come out worse than Java-style documentation of getters and setters (meaning: “This getter function gets the value of the variable,” etc.).

In total, scrubbing code comments saved me almost 20% of the codebase, though I did have to add back in the select few “necessary” comments.

The next part was not as easy to scrub out.

## LLMs Are Also Bad at Instrumenting Code

Given that I’m coding with an LLM, it makes a lot of sense to have a lot of `print` statements because I can feed the LLM 1,000 or 5,000 lines of console output, then the LLM can process it almost immediately to figure out what happened incorrectly in the execution flow.

Since I’m using a state chart as a centralized [single source of truth](https://archive.is/o/PUYt6/https://en.wikipedia.org/wiki/Single_source_of_truth), I almost never need breakpoints or the debugger because I’m almost never experiencing bugs that are a consequence of some type of state issue.

I have 100% ownership of my code with no external libraries and no tech debt. So I’ve found that almost all my game’s bugs are because the code didn’t execute in the right order: flow bugs, not state bugs.

The Godot game engine in particular seems to be famous for having race conditions, though I would imagine that any tick-based game engine would suffer from a lot of race condition problems.

I got into the habit of having the LLM instrument everything with unnecessary `print` statements so that when inevitably the LLM failed to achieve the goal, my debugging cycle would be that much quicker.

Unfortunately, what started off as a useful way of “debugging as I go” became this enormous amount of useless `print()` statements in my code.

In fact, the game was trying to print so much console output at one time (on enemy turns) that it would pause and freeze the gameplay.

Obviously, that means that I wouldn’t be able to release the game if that was happening. But given that I’m 12–18+ months away from release, more importantly, it was affecting my playtesting. Plus, it was just dumb. 😅

At this point, I was still naive and I thought that, okay, I’ve scrubbed the code comments. Now I just need to scrub the console `print` statements and I’ll be good to go.

However, I had some issues using Search and Replace in Files to remove the `print` statements. I started using the LLM to do it file by file. Since I had 90 game files, that took a while, but it wasn’t so bad.

What *was* so bad is that — as I started scrubbing file by file and I saw the code without any of this meaningless slop obscuring the code, without the “waste of space” code comments and excessive instrumentation — I started to see some deeper issues: I’d let AI slop architecture creep in!

Specifically, since I’m using a state machine (state chart) to manage my application flow, I saw that my state chart wasn’t entirely the boss.

I was pretty happy I caught this because it explained a specific type of bug I was having with backing out of gameplay menus. But it also meant that the AI slop was deeper than *just* code comments and `print` statements.

I powered through file by file and pulled out another 30,000 tokens of now deleted `print` statements, or about 15% of my codebase, noting every architectural anti-pattern that I saw while I went so I could address them.

Once I’d done that, I realized what the real problem was, which is that I had let the LLM architect some aspects of the game logic. Whoops! ️🤦♂️

As you might guess, it had done a truly awful job with the architecture.

Here’s what I found.

## LLMs Lie All the Time, and I’d Forgotten That

It was my mistake, of course. I had been assuming that — since I had repeatedly instructed the LLM to ask questions if anything was unclear in any way — that it would *follow* those instructions and *ask questions*.

Unfortunately, as any SWE who’s tried to use an LLM knows, the LLM will just confidently [hallucinate (confabulate) plausible-sounding BS instead](https://archive.is/o/PUYt6/https://medium.com/according-to-context/ive-found-the-3-sources-of-ai-hallucinations-here-s-how-to-fix-each-5403776448b7).

## [I’ve Found the 3 Sources of AI Hallucinations. Here’s How To Fix Each.](https://archive.is/o/PUYt6/https://medium.com/according-to-context/ive-found-the-3-sources-of-ai-hallucinations-here-s-how-to-fix-each-5403776448b7)

### Large language models (LLMs) prefer a confident tone whether or not their information is correct, resulting in what are…

medium.com

Case in point, I had been sending my state machine code as part of my codebase text file that I create with `repomix`, and at some point, I had moved the file such that repomix wasn’t including it.

Thus, I had stopped sending my game’s state chart to the LLM.

As you’d expect, the LLM didn’t ask where the state chart file had gone; it just stopped using the state machine for new functionality, and I ended up with a really bizarre spaghetti architecture.

In spaghetti land, half the game was managed by the canonical state chart of gameplay flow, and half the game was just a mixture of random input handlers strewn haphazardly throughout the codebase. 😔

At this point, I’d only been trying to scrub the AI slop for a few days, and I figured that it wouldn’t take me that much longer.

It took me another 2 weeks to scrub out all the bad architecture — meaning I’d spent 3 weeks refactoring and 6 weeks since I’d first identified the bug of “backing out of menus is not working correctly.”

Of course, I felt like an idiot.

I felt really bad about having let it get to that point. I felt guilty for making wrong assumptions about the context I was providing the LLM, plus I hadn’t put sufficient guardrails around my LLM (i.e. to always confirm the presence of the state chart) nor had I reviewed the code well enough.

This was definitely a consequence of this being my first Godot project, though I think a similar type of wisdom applies to all LLM coding:

- **Plan the code yourself, don’t let the LLM architect it.**

The other thing that happened is I’d started using Deep Think, and [Deep Think has a 192,000-token limit, so I started bumping up against that](https://archive.is/o/PUYt6/https://medium.com/according-to-context/gemini-3-first-impressions-benchmarks-including-deep-think-40a00a622e8d), and also Deep Think can take up to an hour to run sometimes.

## [Gemini 3 First Impressions & Benchmarks (Including Deep Think)](https://archive.is/o/PUYt6/https://medium.com/according-to-context/gemini-3-first-impressions-benchmarks-including-deep-think-40a00a622e8d)

### With the release of Gemini 3 Thinking replacing Gemini 2.5 Pro, will my coding workflows survive? Here are my…

medium.com

In trying to use Deep Think, I made the wrong assumption that this “exorbitant LLM product with better coding benchmark performance” would work better for my use case, but no, it just hallucinated, a lot!

Worse yet, in redoing [my “iterative” 5-step forge workflow](https://archive.is/o/PUYt6/https://medium.com/according-to-context/my-5-step-forge-for-better-llm-coding-for-swes-920e510de9f6) to be a “give it to me all at once in one giant message” 5-step forge workflow (for Deep Think), I let my habit slip. Previously, I had always meticulously checked the planning and corrected it; with Deep Think, I hadn’t done so.

## [My 5-Step Forge for Better LLM Coding for SWEs](https://archive.is/o/PUYt6/https://medium.com/according-to-context/my-5-step-forge-for-better-llm-coding-for-swes-920e510de9f6)

### I’ve been finding much improved results using LLMs to code by disagreeing with the core tenet of “vibe coding” — that…

medium.com

Even with all my context engineering, I have to correct the plan the LLM generates if I don’t provide one more than half the time.

When I was using Deep Think, I was skipping that.

But since the code would seem plausible and often it would run, I was just missing the fact that the architecture is really bad.

I’d turned into a vibe coder!!! The horror!!! 😱

Jokes aside, I’d failed to do the most important steps myself: planning the complete user interface, game behavior, and state chart in detail, based on the specific requirements of my game.

Letting the LLM code when the architecture and constraints are right is usually faster than I can type, but as soon as I let “vibe architecture” creep in, I’d really shot myself in the foot.

Here’s how I cured myself of anti-patterns and vibe architecture, permanently, while still getting the benefits of using LLMs to code.

## Vibe Architecture = AI Slop Architecture = Bad

The AI slop architecture problems in my codebase came down to 3 specific types of things I had to scrub out:

1. Useless signal connections that turned 1 line of sending an event to the state chart into 10 or more lines of code, often across multiple files.
2. Splitting game state into multiple places by duplicating state variables across multiple files unnecessarily, rarely trying to sync them.
3. Race conditions and wishful thinking during the startup process resulting in extreme difficulty adding any new service because there was no specific reason the services were starting up in the correct order. There was no enforcement that the services must start up in the correct order, so every time I’d try to refactor, game startup broke.

If you’re familiar with Godot, you might understand a little bit about what happened to me here. I ended up with a mixture of autoloads (global classes or singletons) and instantiated scene nodes (objects that have been added to the scene tree and exist as local instances, not globals).

Of course, globals are great for things that are truly static, but I had “magic spaghetti” I had to exorcise scattered all over the codebase in the form of signal connections, duplicated code, and managing execution flow through the state chart only in *some* cases and not at other times.

It was my own fault, of course, but I’d say the main difference between a “vibe coder” and a “lead SWE using LLMs” is that the former gives up on the codebase rather than understanding, fixing, and rearchitecting it.

![](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*FaaBiV_kpLIkPmGNsq7QnA.png)

(AI-generated diagram prompted & upscaled by )

I committed to fixing it — despite my guilt and feelings of negativity about the state of the project — and buckled down to rearchitect the code.

Compared to the first few tasks, this task was much harder.

I added more than 20 separate “pillars of Godot code” (you can use any word, but I picked “pillars” as my word for this concept) to my context engineering document to prevent these types of architectural mistakes.

## Godot-Specific Issues and My Anti-Slop Pillars

Of course, I made sure to start sending the state chart over to the LLM with `repomix` by updating my `repomix.config.json` file. That was my original mistake that resulted in much (but not all) of my slop architecture.

Confusingly, the state chart is a scene *node* (`.tscn`, not `.gd` scene *script*) in the Godot scene tree, not a global, even when used as a “global” state chart.

While I love [Godot State Charts](https://archive.is/o/PUYt6/https://derkork.github.io/godot-statecharts/) (the plugin I’m using), the approach of having “separate scenes” that Godot uses (that Godot State Charts also uses) where “not everything is a `.gd` or `.cs` script file, sometimes they’re `.tscn` scene nodes” was pretty confusing to me, coming from TypeScript.

In other words, Godot has a GUI, and you *have* to use the GUI, because that is how the engine works, I guess because “that’s how game engines work.”

In my SWE career, I hadn’t used a GUI “for coding” in ~20 years (not since Macromedia Dreamweaver), but now I get how Godot works. 🤷

Once I was sending the state chart, I thought it’d be easy to fix the rest, but it took me 5 passes through the entire codebase to scrub everything.

For example, the LLM loves creating what I call [code bureaucracy](https://archive.is/o/PUYt6/https://news.ycombinator.com/item?id=22354306), where there is code that exists that could be written shorter but really only seems to exist to justify dysfunctional engineering practices in corporate jobs.

A great example of unnecessary, pointless code bureaucracy is having a signal or event that doesn’t do anything. It just moves the responsibility elsewhere, instead of just handling whatever needs to be done, such as updating game state or sending an event to the State Chart.

That may be an effective approach for “closing Jira tickets at work,” but it makes the logic incredibly difficult to follow and debug, for no benefit.

I started writing down “pillars,” starting with one pillar apiece for no code comments and no `print` statements (no instrumentation).

These architectural concerns turned out to be 25 pillars. It would bore you to tears to read the pillars in their entirety, but I'll give you the flavor:

- **The Pillar of No Code Comments**
- **The Pillar of No Instrumentation**
- **The Pillar of No Unnecessary** `**if**` **Statements**
- **The Pillar of No Code Duplication**
- **The Pillar of Composition Over Inheritance**
- **The Pillar of No Getters/Setters**
- **etc.**

This step was the hardest by far. And like I mentioned, it took a full 2 weeks of scrubbing code files to accomplish.

![](https://miro.medium.com/v2/resize:fit:720/format:webp/1*ncxibem79kiq32z30NeDzQ.png)

(AI-generated diagram prompted & upscaled by )

## Reflecting on My 25 “Anti-Slop” Architectural Pillars

The biggest challenge was that a priori (ahead of time) I didn’t know what all the architectural problems were going to be.

Often, I’d be tackling 5 or 10 architectural problems, and I’d find out, oh, there’s another one I need to add.

For a while, it felt like there was always another architectural issue I needed to tackle, which put me in a bad mood.

Of course, it was another bad assumption on my behalf, so I need to take accountability for it: I needed 25 pillars, not 5 or 10, to fix the problems.

In the end, I went through, file by file, scrubbing the codebase of bad architecture. I did this “file by file” step 2 times in a row.

Then I did what refactors that were affecting multiple files at once, sort of in a system-by-system process.

I broke down the “big refactors” into several passes: first for State Chart events, and then to remove all unnecessary signals from the codebase, leaving only signals that were properly used to trigger necessary side effects (such as showing UI animations in other components).

After that, I had to go back and scrub each file again to finish removing all of the signals and code duplication.

Last, but definitely not least, I did a final pass without the LLM, proofing the entire codebase line by line myself.

The bottom line? I needed to take ownership of the codebase and accountability for the bad architecture, so I did exactly that.

In total, it was at least 5 passes to scrub out the slop architecture, which is why I highly recommend preventing slop architecture in the first place.

All this work only reduced the code by another 10%, or about 15,000 tokens, which was less than I’d saved in my first 2 “anti-slop” phases.

By volume (amount of code removed), the `print` statements and code comments were much bigger problems. Keep that in mind as well.

![](https://miro.medium.com/v2/resize:fit:720/format:webp/1*t8wEZCUByRHfwkhjU51iTg.png)

(AI-generated diagram prompted & upscaled by )

However, the architecture work was way more valuable than removing instrumentation and comments, in terms of improving the game’s code!

## 3 Weeks of AI Slop??? Why Even Use LLMs To Code?

In total, it took me 3 weeks of full-time development work to scrub out 100% of the AI slop from my codebase.

Yes, that is the exact argument of “LLMs are useless for coding” that some SWEs make, and I see their point. [LLMs have many better uses for SWEs!](https://archive.is/o/PUYt6/https://doctorderek.medium.com/coding-with-llms-is-far-from-the-best-use-case-of-llms-for-swes-b17598abb45a)

It’s *not* faster to use LLMs for code if it takes 30–50% of your time “redoing work,” similar to [how it’s not faster to use unskilled SWEs. It’s just math.](https://archive.is/o/PUYt6/https://medium.com/career-programming/most-senior-software-engineers-are-useless-heres-the-math-to-prove-it-061863418429)

But this experience of scrubbing out all the AI slop left me feeling extremely *optimistic* about using LLMs to code, and I continue to do so.

Why? Because LLMs fail in predictable ways for the most part, and [LLMs mostly follow instructions](https://archive.is/o/PUYt6/https://medium.com/p/920c4bfdd965). I simply “programmed” the slop out by documenting the anti-patterns in my context engineering document.

## [How To “Program” LLMs Like You “Code” a Program with Instruction Following](https://archive.is/o/PUYt6/https://medium.com/according-to-context/how-to-program-llms-like-you-code-a-program-with-instruction-following-920c4bfdd965)

### LLMs can, in fact, be “programmed” to “execute” functions, similar to coding, due to instruction following. Here’s what…

medium.com

The more I identified and banned each and every anti-pattern in my context engineering, then the less mistakes the LLM has made ever since.

Of course, you still can’t *trust* the LLM! (Never trust LLMs!). When I went to run my game, it still took me another few days of debugging to get things back working as well as they had been before I started refactoring things.

Of course, in reality, they’re working way better because I eliminated entire classes of bugs, such as: *Does the B button on the controller sometimes open the pause menu or sometimes back you out of a menu?*

In my game, “B” does both, but it’s dependent on the game’s currently active state in the state chart. Now I don’t have that bug anymore, at all.

But what I mean by you can’t trust LLMs is that the LLMs’ system prompts balance instruction following with sycophancy (and “expert” arrogance).

If I make a mistake and tell the LLM to keep making this mistake, then the LLM, generally speaking, won’t push back — that’s the sycophancy in action. And then I’ll just have a mistake in my code.

But if I ask what I’m doing wrong, or if I try to let the “arrogant expert” LLM debug architecture without guidance, it will just make stuff up and lie.

A great example is that I was trying to refer to my top-level parent nodes in the scene tree by their unique variable names, which in Godot are prefixed with the percent sign: `%GameStateManager` and `%BattleMap`. Those should both be in code and should be PascalCase.

In Godot, that is only a valid way to refer to a child node in the tree, not a parent node. Personally, I don’t find that fact obvious at all despite reading a ton of Godot docs, but it’s just a consequence of the fact that Godot looks down in the scene tree and then tells its parent that it’s finished looking down at its children and now it’s ready. Whatever.

In those cases, I had to either refer to the node as its parent using `get_parent()`, or the absolute path: `get_node("/root/Main/GameStateManager"),` as I could only find the children nodes using the percent sign.

Every language and framework and engine has tons of quirks and this is just a Godot quirk. No big deal, right? The LLM should have corrected me.

Instead, the LLM just let me make that mistake in 100% of the codebase.

Then I had to go back and fix every example in the codebase with my new understanding and update my pillar in my context engineering document.

Chiefly, the LLM will reproduce any patterns that are currently in the codebase because that’s just how it works.

Typically that’s the behavior you’d want any SWE to exhibit, right? Follow the existing patterns in the codebase, as long as they’re correct code.

But, since the LLM can’t differentiate between “reality” and “mistakes” without just making incorrect assumptions (arrogant “expertise”), that becomes an extremely common failure point for LLMs: they multiply existing slop, meaning AI slop has a tendency to increase exponentially.

In other words, if there are already any anti-patterns of any kind in my codebase, the LLM will happily reproduce those.

The AI slop multiplies like slime, and that was exactly my experience.

That’s why we SWEs understand that “vibe coding a prototype” and actual software engineering are different approaches to making software.

It also had me feeling pessimistic about LLM-assisted SWE, but now with all the pillars in place (and no anti-patterns left in the code) my velocity is back up to “faster than I’d be without the LLM,” without any AI slop! 🥳

## Wrapping Up: Now There’s 0% AI Slop in My Code

My point is that it can be hard to get LLMs to generate well-architected code, especially if you have preferences for what you consider anti-patterns, like I do (such as I prefer “ [composition over inheritance](https://archive.is/o/PUYt6/https://en.wikipedia.org/wiki/Composition_over_inheritance) ”).

That doesn’t mean LLMs are *useless* for coding for SWEs, though.

Despite all the AI slop, it’s not like I’ve stopped having the LLM generate 100% of the code; I simply no longer allow any AI slop to creep in.

Because I have now scrubbed out every anti-pattern that the LLM ever tries to use under any circumstances, I find it easier to review every line of the code and see whether the LLM is giving me slop.

Similar to how it’s difficult to review “crap” code full of useless (or wrong) code comments, it was difficult for me to stay motivated to review the LLM-generated code before I scrubbed the slop. Now, it’s easy to do so.

I’m also taking responsibility for letting myself get into this place where I was so focused on the joy of gameplay that I let these kinds of mistakes happen, what we might call “the curse of the vibe coder.”

I know it would have been a lot faster to catch each class of mistake as I went and to create a new pillar in my context engineering document one at a time, instead of going back with a “code mop” to try to clean it all out at once in a giant refactor. (Deferring tech debt is rarely a good idea! 🧹)

I also want to note that when I started the refactor, the game was working well, but not great. That’s what clued me in to the slop in the first place.

It’s not like the game wasn’t working *at all*; it’s not like the code was *mostly* wrong; and it’s not like I didn’t *understand* all of the codebase.

It’s just that the sheer amount of AI slop — especially in terms of bad comments, bad instrumentation, and bad signals spread across 90 files — was obscuring the specific architectural mistakes that were affecting gameplay and future maintainability of the codebase.

The “comment and instrumentation slop” were the easiest to scrub out but had no effect on the architecture or gameplay, only code readability.

I think it’s also really easy to take the wrong lesson from my giant refactor and think that LLMs are useless for generating code.

They’re not, but they need guardrails, including not only my 25 coding pillars but also immediately starting a new chat if the LLM ever makes a mistake, often with an update to the context doc to prevent that mistake.

I guess I’ve just worked in so many low-quality codebases full of multi-thousand-line crap files with no useful documentation, no strict types, and a million other mistakes and anti-patterns to be miffed at the low quality of the “AI slop” code that the LLM had given me.

Let me put it that way: the worst “AI slop” I removed from my game’s codebase was far from the worst code I’ve ever seen in production!

I personally have even paid money for worse code from a human who was not very good at coding than the slop code I refactored out.

At the same time, the reason I wanted to share all this advice and my experience with you is because it’s just so much easier to catch the mistakes and update your context document that you start every chat with (or `agents.md` if you’re using that) as you identify each architectural anti-pattern one by one, than it is to try to refactor the entire codebase at once.

Personally, I’m just overjoyed to be back actually working on game development instead of just scrubbing out (or being forced to ignore) tech debt like I used to working as a lead SWE inheriting craptastic codebases.

Please let me know in the responses below whether you got something out of this article.

I’d love to hear what your experiences have been in removing and preventing AI slop in your own codebases during your work as an SWE.

What are your tips for me and everyone else about AI slop prevention?

**Happy coding (and preventing slop)!** 🤖

![](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*jBtJYRQR8luqTgqVFQxqHQ.jpeg)

Ah, our cat Yuma is sleeping the sweet sleep of slop-free code. 😸 (Photo by )