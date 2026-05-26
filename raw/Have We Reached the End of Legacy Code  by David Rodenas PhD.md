---
title: Have We Reached the End of Legacy Code? | by David Rodenas PhD
source: https://freedium-mirror.cfd/medium.com/@drpicox/have-we-reached-the-end-of-legacy-code-dc65c7c67cdd
author: "[[David Rodenas]]"
published:
created: 2026-05-26
description: The cure for technical debt has existed for decades. We just never had anyone disciplined enough...
tags:
  - clippings
---
[< Go to the original](https://drpicox.medium.com/have-we-reached-the-end-of-legacy-code-dc65c7c67cdd#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/1*HyViyFV1eflV18jGdnGW7w.png)

## Have We Reached the End of Legacy Code?

## The cure for technical debt has existed for decades. We just never had anyone disciplined enough to apply it. Until now.

a11y-light · May 16, 2026 (Updated: May 16, 2026) · Free: No

*One of the biggest worries in the programming world is technical debt, and in its most extreme form, legacy code. We know that as code evolves, if we do nothing, technical debt keeps piling up until it reaches the extreme case of turning into legacy code. But… what if we were at the end of technical debt?*

### Technical debt

Evolving software isn't simple. Every change means integrating the new code with the existing code, and that isn't always easy. **The existing code usually didn't anticipate future changes, and even when it did, they were never the exact changes that had to be made**. So you have to keep updating and cleaning things up along the way.

But often, those updates and cleanups never happen. The day-to-day pressure, the lack of vision about what's coming tomorrow, starts making it harder to add new code. The friction keeps growing, and so do the delivery times.

This goes on until there comes a point where **touching the existing code starts to feel scary.** Not only is it complicated to update the existing code, but there's a high chance of breaking what's currently working. Technical debt starts turning into legacy code.

**And this creates a negative spiral**. To avoid making a change in the code that might inadvertently break a feature, even more technical debt gets added. And at the same time, this creates even weaker links between the various parts of the code, ones even more likely to break. Making even more changes necessary, which in turn add even more technical debt.

Often ending in the typical request: " *we need to rewrite the code* ".

![None](https://miro.medium.com/v2/resize:fit:700/1*QQ9M-ug5sXfMnyyeUNCdRw.png)

### Code maintenance

Looking at this negative spiral, one thing we see clearly is that it starts from a single fact: a lack of maintenance, or of code cleanup.

Many times this lack of cleanup comes from the pressure (or the urge) to deliver quickly, and a lot of that cleanup is seen as unnecessary because the code already works. Other times the code just seems good enough, not out of haste, but because making more changes doesn't seem to make any sense. And on rare occasions there's an even bigger problem: a new relationship between several parts of the code has been created that requires rethinking and restructuring the code to make future changes easier, or to better understand the relationship between the parts today.

The question is, could it somehow be avoided?

The industry's recommendation for years has been what we can sum up as the Boy Scout Rule:

> "always leave the code better than you found it."

It's simple, it draws a parallel with camping trips where you're always asked to leave the forest cleaner than when you arrived, cleaning up what we find that someone else might have left behind, and we do the same with the code. With this rule, not only do you prevent technical debt from growing, but over time, you progressively reduce it.

But the problem is obvious. It's hard for a developer to be applying this rule for every single feature. **It's a matter of discipline and staying alert, and since it isn't natural**, and the environment itself doesn't help either, **it ends up being set aside**. Because if we think about it as a one-off thing, at the moment of tidying up, it's easy to follow the rule. But in the day-to-day, when this has to be applied on every delivery, the rule ends up taking a back seat and gets forgotten.

### Legacy code

When the code starts to be very deteriorated we begin to enter the next phase, the legacy code phase. This is the moment when the developer starts to be afraid to touch the code. When a change can end up triggering a feature failure in an unexpected place.

And not only that. In this phase the software also starts to be big and old enough that the developers, and even the business people, start to forget all the features that have been implemented over time. And even if there were a record of all the features that have been added, there's no one able (or with the time) to read them all, to know which ones still have to keep working and which don't, and to have a clear picture of everything the software is supposed to do.

To deal with all this the industry has a common practice: QA testing. Whole quality assurance teams are usually created that manually run the application to see if it fails. In many cases they even end up creating automated tests that verify certain features. The idea is simple: before a user discovers a bug from a change that's been made, it's better for a QA to discover it first by using the product the same way the user would.

But, even so, when it's done after the fact, there's an essential problem:

> what is a feature and what isn't?

Because little by little the product has been growing, adding features, and making concessions to whatever the code dictated. **Part of the behavior is there because it's what was wanted**. **Another** part of the behavior is simply **undefined cases** that have been filled in by the **interactions between the lines of code**. **And others are just developers' opinions**.

And it's not unusual either to come across **QAs who open as bugs features that were requested in the past**. Simply because they seem strange and it's hard to find where they were documented.

### Can it be slowed down?

For a few months now we've started seeing tools like GitHub Copilot do automated reviews of developers' pull requests with quite a lot of accuracy. Reviews that are not only able to see the nitty-gritty of the code and detect errors in it, but are also able to detect the very intent of the code. So this tool not only points out what it considers poorly written or not following high enough quality standards, but it's also able to understand the context in which the feature was built and suggest improvements or use cases that maybe haven't been taken into account.

Well, one of the main problems with the Boy Scout Rule is that in day-to-day software development it gets parked to one side sooner or later. Developers are focused on each delivery, and making a pause, even a small one, tends to introduce friction. So the question is, could we change the environment to encourage this practice? Or even better:

> could we delegate this practice to a tool that doesn't forget what we ask of it and will follow the rule?

That's where the question lies.

**The technology allows it, what we don't know is how well it would do it.**

The idea seems simple: if on top of a process like the GitHub Copilot review we add a code cleaner, this technical debt reduction phase would be automatic. Just as now for every PR a whole series of change recommendations appears, and even the option for the AI to fix it, you could simply automate it so it applied them directly. With approval requiring a review not only of the developer's code, but also of the code from the AI that did the cleanup.

A step that's easy to approximate right now by changing the reviewer's instructions, where it should be asked, following clean code standards, to look at all the technical debt and propose improvements. And once they're detected, asking the AI to fix it on its own should be enough.

> And at night too, because the cleaning could be left for nighttime. That way, first thing in the morning before doing anything, you could review and incorporate the changes. Changes that wouldn't be limited to a single PR, but changes that would look at the structural relationship between several parts, doing a deeper cleanup. And it would have the extra beneficial effect that developers would have an added incentive to do continuous delivery: any work that isn't delivered daily would run the risk of being affected by conflicts the next day.

### Can it be reversed?

All of this has been about doing cleanup along the way, but… what happens once the code has gotten so complicated that any change at all can cause unpredictable defects?

In this case the cleanup can be seen as a risk point, because every change has to be deeply validated. So you couldn't trust how it works.

But there's another path.

Here you need to take advantage of some different AI capabilities: the ability to read documentation, to create automated tests, and even to test applications "manually".

Because in this scenario **what's needed is to fortify the code**. To get a way to determine whether a change breaks something or not. And for that, testing, and above all and most importantly, knowing what to test is hugely important. Because with software that has grown, and that has gotten out of control, it's even hard to know what was and wasn't a feature.

So the path here is long, complicated to some extent. But possibly feasible.

The AI should start by reading the code, reading the whole commit history, the development ticket history, the defect history. And start forming hypotheses. Its job would be to find the software's expected behaviors. For each of them, check whether it really referred to an expected behavior, or to the resolution of a defect, and check that it hadn't been changed at a later point. Once that's confirmed, create the software test to verify that it shows that behavior, and verify that the test really is checking that behavior (usually by finding a way, or even changing the code, to force it to fail for that reason). And little by little keep creating all the tests needed to fortify the code.

And once we have all the tests, then we can start modifying the code. So that if at any moment a test fails it will tell us which behavior has been broken, we'll be able to validate whether it was expected or not, and we'll be able to decide whether to go ahead or not, or look for an alternative. And all of this before reaching QA, and above all, before reaching the end user.

> It's necessary to stress the importance of having it look for and test software behaviors and not test code (unit tests as defined by QA), because testing code is what creates rigid code that can't adapt. By testing code, any change to the code would make the test fail, and it wouldn't help us keep improving the internal design.

### Where the limit was

If we look closely, **all the defenses against legacy code shared the same blind spot**.

## [What Clean Code and Fighting Global Warming Have In Common?](https://drpicox.medium.com/dirty-code-and-global-warming-27f04623178d)

### A Tale of Human Behavior, Individual Gains and Shared Future Costs.

medium.com

The Boy Scout Rule depended on someone remembering to clean up on every delivery. QA depended on someone remembering what was a feature and what was simply an accident of the lines of code. And rewriting from scratch depended on someone remembering why the code did what it did. Always, in the middle, there was a human who had to not forget.

And that was the problem. Not the lack of tools, not the lack of knowledge. The cure had been known for decades. What was missing was someone who could apply it delivery after delivery, without getting tired, without the day-to-day pressure sweeping it away, without ever forgetting what had been asked or why. And that isn't something a human can do well. It never was.

The limit, then, wasn't technical. It was us, trying to keep clean something that grew faster than we could remember. And for the first time, the "not forgetting" can stop depending on us.

Maybe we haven't reached the end of legacy code. But we have reached the end of the reason we always ended up there.

***Thanks for the read.*** *I usually like to write stories to think about how we understand and apply software engineering and to make us think about what we could improve.* ***If you liked the article, don't forget to clap, comment and share.*** *For more insights and discussions,* *[explore my most successful stories on Medium](https://drpicox.medium.com/my-most-viewed-stories-95b5d96ade0e)**, or just check out my book where I* *[tackle both code and coder struggles](https://www.amazon.com/Emotional-Technical-Stalled-Software-Stories-ebook/dp/B0DL4P6VMQ/ref=sr_1_1?crid=1EEGWY92O1S8Y&dib=eyJ2IjoiMSJ9.etnWLbICimbZq9REdD_kk0t-4oh15iNX6Sjo4Ke_PlHGjHj071QN20LucGBJIEps.wXbiW0NN1-HN_GvoaQkjMLMz-U4dxiwonbf7a7DwXpY&dib_tag=se&keywords=david+rodenas&qid=1745049491&sprefix=david+rodenas%2Caps%2C177&sr=8-1)* *(maybe obsolete today?).*

[< Go to the original](https://drpicox.medium.com/have-we-reached-the-end-of-legacy-code-dc65c7c67cdd#bypass)