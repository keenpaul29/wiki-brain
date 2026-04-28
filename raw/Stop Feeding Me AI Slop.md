---
title: "Stop Feeding Me AI Slop"
source: "https://medium.com/datadriveninvestor/stop-feeding-me-ai-slop-a4bf084b09c9"
author:
  - "[[Kirill Bobrov]]"
published: 2026-04-10
created: 2026-04-28
description: "Now the 1x engineer can become a 10x, and 0.5x engineer can become 5x engineer but there is a catch"
tags:
  - "clippings"
---
## Now the 1x engineer can become a 10x, and 0.5x engineer can become 5x engineer but there is a catch

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*29D6Izcwxz03hXcq.jpg)

I see it everywhere now. Code reviews. Design proposals. Technical specs. Slack messages. LinkedIn posts where every sentence sounds like it was marinated in the same corporate-bullshit soup. Blog posts that take 2,000 words to communicate one idea that fits in a tweet.

AI slop — it’s the defining aesthetic of 2024–2026 professional communication. I see it in open-source repos, Slack communities, docs from friends at other companies, and my own review queues.

And I’m done pretending it’s fine.

Yes, I use AI constantly — I’m writing this with one open in another tab. This isn’t an anti-AI rant. It’s an anti-laziness rant.

## The Problem Isn’t the AI

I’m not raging at AI as a tool. I use it constantly — it drafts, refactors, and helps me think through problems out loud when I don’t have a buddy engineer to rubber-duck with. The tool is fine. Great, even.

The problem is what happens when people stop thinking and just… delegate. When the AI isn’t amplifying your thoughts, but *replacing* them. And the problem becomes even more of a problem when the output of that delegation lands in my inbox, my feed, and every technical document I touch, and I have to deal with it.

AI writing has a signature. It’s verbose in a very specific way — confident-sounding but somehow content-free. It will give you five paragraphs where one sentence would do, and that one sentence would still be vague. It loves to overuse certain phrases such as, “it’s worth noting that” and “in order to”, and often defaults to organizing by fake structure: three bullet points that all say the same thing with different nouns. It sounds thorough. It is not.

And when you push back, ask a clarifying question, try to get to the actual decision behind the document — the author goes quiet. Or they send you more AI-generated paragraphs. Or they directly admit that they clearly haven’t read what they sent you. Because they didn’t write it. They prompted it and didn’t bother to digest the output.

That’s where I get off the train. If your entire contribution to a technical discussion is copy-pasting ChatGPT’s or Claude’s take, *what are you adding?* **You are the entirely unnecessary, expensive, slow, unreliable meat-based middleman in this exchange.** I’d rather talk to the LLM directly — at least it answers follow-up questions coherently.

The value of human communication is **distillation**. I am relying on you because you’ve allegedly been thinking about this problem for a week. You’ve allegedly hit dead ends I haven’t. When you do the work, gain the knowledge and communicate coherently about it, you give me a concentrated signal I can build off of. When you outsource the thinking and writing, I get homework instead of assistance — on top of reading your 15-page slop document, I now have to do all the thinking on my own.

## What This Looks Like in Engineering

The place I find it most damaging is in design documents. A good design doc is an artifact of actual thought. It shows you understood the problem well enough to consider multiple approaches, reject some, pick one, and explain why. The act of writing it is where a lot of the design actually happens. You start writing, *“we’ll use Kafka for this”*, and then you have to justify it and you realize you actually can’t, and you end up redesigning the whole thing. That’s the process working.

An AI-generated design doc skips this entirely. It gives you a beautifully structured document with all the right sections — background, requirements, high-level design, options considered — all filled with plausible-sounding content that nobody actually thought through. The “options considered” section is particularly egregious. It’ll list three alternatives with superficially reasonable tradeoffs that have nothing to do with your actual constraints. Despite the title, nobody considered these alternatives. Then the document gets approved because it *looks* thorough. Six months later someone’s implementing it, hitting the exact edge cases that were never thought through and the person who wrote the doc can’t explain the decisions because they didn’t actually make them.

PRDs (Product Requirement Docs) are the same story. I’ve seen product requirement documents across teams and companies that are essentially just a rephrasing of the feature request with AI-added structure. No thinking about edge cases, no signal about what the PM actually believes matters, no prioritization that reflects real judgment. Just prompt output with a title and a JIRA ticket.

Code review comments are getting the same treatment too. You’ll see a verbose explanation of a code pattern that’s technically correct but has nothing to do with the specific code being reviewed. Generic. Could have been posted on any PR in any codebase. The reviewer didn’t think about your code. They asked AI to comment on it and pasted the result.

![](https://miro.medium.com/v2/resize:fit:1100/format:webp/0*OTubPXe0OQ54RHJd.jpg)

## The Tool vs The Replacement

Good news — I think there’s a version of this that isn’t a problem. I use AI to write faster all the time. I’ll think through an architecture, sketch the key decisions, then ask the the AI to write the prose. The thinking is mine. The language is assisted. What you get from me is still my distillation — it’s just faster to produce (and with fewer grammatical errors).

That’s proper use of the tool, in my opinion. When you haven’t done the thinking and you’re using AI to simulate the appearance of having done it, you’re replacing yourself and your work with a simulacrum. That’s fraud.

![](https://miro.medium.com/v2/resize:fit:1100/format:webp/0*BLFpQrV7xBqTHGUI.jpg)

The tricky part is that the path between them is very short, and the incentives are all pointing the wrong way. Writing a real design doc is hard and slow. Writing a prompt is easy and fast. If reviewers can’t tell the difference — and often they can’t, at least on the surface — why bother?

The result is gradual erosion. Standards shift. The average quality of technical communication slowly degrades, and nobody calls it out because individually it’s always “good enough”. Until it isn’t.

## The Dangerous Part

Think of AI as an amplifier. A 2x engineer with AI becomes a 5x or 10x engineer. But an engineer with negative judgment? AI amplifies that the same way. Bad decisions get made faster, but look more polished, and are harder to argue with because they’re wrapped in **confident, well-structured bullshit**.

![](https://miro.medium.com/v2/resize:fit:1166/format:webp/0*-C92o85UhCcZH14l.jpg)

Most of this is just annoying. But some of it is actually dangerous.

When an engineer merges code they can’t explain, it’s a problem — and it’s been a problem since before the modern age of LLMs. But at least before, the engineer still usually understood *most* of it. Now, I’m seeing PRs — in open source, in professional codebases, in side projects friends ask me to review — where the author clearly generated the implementation, made it pass the tests, and shipped it. They can’t walk me through the logic. They can’t explain why they made that choice in the error handling. And when it breaks later that night, someone’s on call with a runbook that was also generated, diagnosing code nobody actually understands.

The docs-that-nobody-owns problem compounds this. If you didn’t think through the design, you can’t defend it when requirements change. You can’t adapt it. You just rewrite from scratch with a new prompt, and now the codebase has two inconsistent design philosophies because both were generated without any continuity of thought. *And now we can produce this failure mode at scale.*

## What I Actually Want

Use AI. It’s a great tool. **But do the thinking first.**

The AI can help you communicate what you think. It should not think for you. If you’re using it to simulate thought you didn’t do, the people on the receiving end will notice. The smart ones notice immediately.

Next time it happens, feel free to send them: [yousentmeaislop.com](https://yousentmeaislop.com/).

What every engineer wants from you is **your distillation**. Your experience with this specific problem. The decision you made and why. No model can generate that — no model has actually lived your context.

The 15-page AI-generated document gives me nothing that a 30-second conversation wouldn’t. Except it takes me 45 minutes to read and leaves me knowing less about your actual thinking than before I started.

Just to make it very simple, here is the diagram:

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*EoOJqHPdn1OnEgMM.png)

**Stop feeding me slop. Think first. Write second. Use AI to help with the second part.**

*Thank you for reading! Curious about something or have thoughts to share? Leave your comment below! Follow me via* [*LinkedIn*](https://www.linkedin.com/in/luminousmen/) *or* [*Substack*](https://luminousmen.substack.com/welcome)*.*

Your Business — On AutoPilot with *DDImedia AI Assistant*  
([Join Our Waitlist](https://waitlist.ddimedia.ai/join-the-waitlist-aie))

Visit us at [*DataDrivenInvestor.com*](https://www.datadriveninvestor.com/)

Join our creator ecosystem [*here*](https://join.datadriveninvestor.com/).

DDI Official Telegram Channel: [https://t.me/+tafUp6ecEys4YjQ1](https://t.me/+tafUp6ecEys4YjQ1)

Follow us on [*LinkedIn*](https://www.linkedin.com/company/data-driven-investor), [*Twitter*](https://twitter.com/@DDInvestorHQ), [*YouTube*](https://www.youtube.com/c/datadriveninvestor), and [*Facebook*](https://www.facebook.com/datadriveninvestor).