---
title: "How I Get 100% Out of AI When Coding — The Workflow Nobody Taught Me | by Udara Abeythilake | in Level Up Coding"
source: "https://freedium-mirror.cfd/medium.com/gitconnected/how-i-get-100-out-of-ai-when-coding-the-workflow-nobody-taught-me-b302b4aaf21d"
author:
published:
created: 2026-05-09
description: "I used to copy paste code from ChatGPT and spend the next three hours fixing it."
tags:
  - "clippings"
---
[< Go to the original](https://levelup.gitconnected.com/how-i-get-100-out-of-ai-when-coding-the-workflow-nobody-taught-me-b302b4aaf21d#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/1*19p3j0OEdzuxSvBKOvH0jA.png)

## How I Get 100% Out of AI When Coding — The Workflow Nobody Taught Me

## I used to copy paste code from ChatGPT and spend the next three hours fixing it.[Level Up Coding](https://medium.com/gitconnected "Coding tutorials and news.")a11y-light ~9 min read · May 8, 2026 (Updated: May 8, 2026) · Free: No

> I used to copy paste code from ChatGPT and spend the next three hours fixing it.

Not because the code was terrible. Because I gave AI zero context and expected production-ready output. I pasted a vague prompt, got a vague answer, and then blamed the tool for not reading my mind.

> That was not AI failing. That was me using it wrong.

After months of trial and error I have built a workflow that consistently produces usable, reviewable, production-quality code from AI. Not sometimes. Not when I get lucky with the prompt. Every time.

The difference was not the AI model. The difference was the process around it.

### Why We Started Using AI in the First Place

Our company made the decision to integrate AI into the development workflow for one reason. Productivity.

Not because it was trendy. Not because someone read an article about the future of coding. Because the team was spending hours on implementation work that could be accelerated without sacrificing quality. The leadership looked at the numbers and saw an opportunity to move faster without hiring more people.

That decision changed how I work every day. But it only changed things for the better once I figured out the right way to use it. The wrong way made things slower because I was spending time fixing AI-generated code that did not understand the project it was being written for.

> The right way starts long before you open the AI tool.

### Everything Starts in Jira

As a developer I live in Jira. It is where the sprint tasks are. It is where the acceptance criteria lives. It is where the discussions happen between the project manager, the client, and the dev team about what exactly needs to be built and why.

All the context for any given task is already sitting in Jira. The requirements. The clarifications from the client. The edge cases someone flagged in a comment three days ago. The acceptance criteria that defines what done actually looks like.

Most developers open AI, type a rough description of what they need, and start prompting from memory. That is the first mistake. You are filtering the task through your own interpretation and losing detail in the process.

The task description in Jira is more complete than your memory of it.

### The Export Trick That Changed Everything

Here is what I do instead.

I export the Jira task as a **Word document** or **PDF**. The entire thing. Description, acceptance criteria, comments, attachments, all of it.

Then I open Claude and open the project that needs the feature. I upload the exported file directly.

Now the AI has the same context I have. Not a filtered version. Not a paraphrased summary. The actual task with every detail the client and the project manager put into it.

If there are additional explanations that are not captured in the Jira ticket, things discussed in a call or a Slack message that never made it into the ticket, I type those out as additional notes alongside the upload.

This takes two minutes. It saves hours.

### Do Not Ask for Code First

> This is the part most developers get wrong.

They upload the context and immediately say build this feature. The AI starts generating code based on its best interpretation of the requirements and its assumptions about the project structure. Half those assumptions are wrong because the AI has never seen your codebase.

> I do not ask for code first. I ask the AI to study the project.

Look at the codebase. Understand the architecture. See how things are structured. See what patterns are already in use. See what libraries are imported. See how the existing features are built.

Only after the AI has ingested the project do I move to the next step.

### The Implementation Plan Is Everything

After the AI understands the project and the requirements, I ask for one thing.

> Give me the implementation plan in markdown format.

Not code. A plan. A structured document that explains

- What will be built?
- How will it be built?
- Which files will be modified?
- Which new files will be created?
- What is the approach?
- Why was that approach chosen?

The **.md format** matters because it is readable. It is reviewable. It is something you can share with another human who can look at it and say yes this makes sense or no this is heading in the wrong direction.

This single step is the most important part of the entire workflow.

### Why the Plan Matters More Than the Code

If you are a junior developer, take that implementation plan and send it to your senior developer. Get it approved before a single line of code is written.

This is not about asking permission. It is about catching bad architectural decisions before they become hundreds of lines of code that need to be rewritten. A senior developer can look at a plan in five minutes and spot a problem that would take you three hours to discover during implementation.

If you are a senior developer or experienced enough to evaluate the plan yourself, that is where most of your time should go. I spend roughly eighty percent of my effort reviewing the implementation plan and only twenty percent reviewing the actual code.

> That ratio sounds backwards. It is not.

Bad code from a good plan is easy to fix. Good code from a bad plan is a complete rewrite.

### Challenging the AI's Decisions

The implementation plan will contain decisions. Which pattern to use. Which service to call. How to structure the data. Where to put the logic.

> Some of those decisions will be wrong.

Not because the AI is bad at coding. Because the AI does not know **your business**. It does **not know the client**. It does not know that the **data model** is going to change next quarter because the client mentioned it casually in a standup. It does not know that the team tried a similar approach six months ago and it caused performance issues that took a week to debug.

> You know those things. That is where your judgment plays a huge role.

When you see a decision in the plan that does not sit right, do not just change it silently. Ask the AI why it chose that approach. Make it explain its reasoning. Sometimes the AI has a valid reason you had not considered. Sometimes it confirms your suspicion that it guessed and your experience tells you a better path exists.

Then you tell the AI what to change and why. Not a vague instruction like do it differently. A specific direction like change this to use the repository pattern instead of direct database calls because we need to swap the data source next quarter.

### Updating Not Rebuilding

> Here is a small but critical detail.

When you need changes to the implementation plan, do not ask the AI to create a new plan from scratch. Ask it to update the existing plan.

This matters because a fresh plan loses the context of the conversation you just had. The AI starts over. The decisions you already approved get re-evaluated. Details get dropped. Things you clarified get unclarified.

Update the existing plan. Keep the conversation's memory intact. Build on what is already agreed rather than starting from zero.

### The Clarification Test

Once you are satisfied with the implementation plan, ask the AI one question.

**Are there any clarifications you need before we start implementation?**

It will ask questions. Always. One or two at minimum. Sometimes five or six.

> This is the most underrated moment in the entire workflow.

Pay attention to what it asks. If the questions are relevant, specific, and demonstrate an understanding of the task, that is a strong signal that the AI knows what it is doing. It is behaving like a good developer would behave before starting work. A developer who wants to make sure they understand the requirements before writing the first line.

If the questions are vague or irrelevant, that is a signal that something was lost in the context and you need to go back and provide more detail.

Answer each clarification one by one. After answering the clarifications, ask the AI to update the plan with the new information.

Now the plan reflects everything you need to implement. Your judgment calls. The AI's understanding. The clarifications resolved. This is a plan you can trust.

### Breaking It Into Steps

Do not tell the AI to implement the entire plan at once.

Ask it to break the implementation into numbered steps. Step one. Step two. Step three. Each step should be a logical, reviewable chunk of work.

This is important for a reason that has nothing to do with the AI and everything to do with you. You need to review the code at each step. Not at the end when there are four hundred lines of changes across twelve files and you cannot tell what was added where or why.

> Small steps. Reviewed individually. Approved before moving forward.

### The Step-by-Step Implementation

Ask the AI to begin with step one. And say this clearly. Do step one and let me review the code before you move to the next step.

That last part matters. Without it, the AI will finish step one and immediately roll into step two and three and four because it is trying to be helpful. You lose the ability to review incrementally and you end up right back where you started with a massive diff that is impossible to evaluate meaningfully.

After the AI completes step one, review the code.

Sometimes you will see a better approach. Maybe you have written something similar before in another part of the codebase and you know a pattern that works cleaner. Maybe the business requirements are going to shift in a way the AI cannot predict and you want to structure the code to accommodate that future change.

Make the adjustments. Provide the feedback. Then approve and move to the next step.

### When You Lose Track

This happens more often than anyone admits.

You step away for a meeting. You get pulled into a bug on another project. You come back to the AI conversation and you cannot remember whether you finished step three or step four.

Ask the AI. Where are we at now.

It will tell you the exact position. Which steps are completed. Which step is next. What was the last thing reviewed and approved.

This is one of those small features that makes AI genuinely useful as a development partner rather than just a code generator. It maintains the state of the conversation when your own memory does not.

### Testing Is Not Optional

Once the implementation is complete and every step has been reviewed and approved, the work is not done.

Ask the AI to write the test cases.

Not vague tests. Specific test cases that cover the functionality you just built. Unit tests for the logic. Integration tests for the connections between components. Edge cases that would take you thirty minutes to think through on your own.

Review the tests the same way you reviewed the code. **The AI might miss a scenario that your business knowledge tells you is important**. Add it. The AI might over-test something trivial. Remove it.

Then ask for the testing scenarios. The manual test cases you or your QA team should walk through to verify everything works as expected. Include the edge cases. The weird inputs. The sequence of actions that real users will inevitably try that nobody thought of during the requirements phase.

### Why This Workflow Works

The reason this works is not because AI writes better code than you.

It works because the workflow puts your judgment at every decision point. The AI does the heavy lifting of generating code. You do the heavy lifting of deciding whether that code is right for this project, this client, this business, and this team.

The AI writes the plan. You approve it. The AI picks an approach. You challenge it. The AI generates the code. You review it. The AI writes the tests. You verify them.

At no point does the AI make a decision that you did not evaluate. At no point does code enter your codebase that you did not read and approve.

That is the difference between using AI as a shortcut and using AI as a multiplier.

A shortcut skips steps. A multiplier amplifies every step you are already doing.

### What This Means for Your Career

![None](https://miro.medium.com/v2/resize:fit:700/0*ZskfDy9IYiDO6-0F)

Photo by [Vitaly Gariev](https://unsplash.com/@silverkblack?utm_source=medium&utm_medium=referral) on [Unsplash](https://unsplash.com/?utm_source=medium&utm_medium=referral)

Every developer I know is either using AI already or about to start. The ones who will get the most out of it are not the ones who type the best prompts. They are the ones who understand their projects deeply enough to review, challenge, and direct the AI's output.

The skill is not prompting. The skill is judgment.

Knowing what the right architecture looks like. Knowing what the client actually needs versus what the ticket says. Knowing which shortcut will create technical debt and which one is a legitimate simplification.

AI cannot replace that. AI cannot sit in the standup and hear the client say we might pivot this feature next month. AI cannot look at the codebase and feel the friction in a pattern that technically works but practically creates maintenance problems.

You can. That is the value you bring. The AI just lets you bring it faster.

[< Go to the original](https://levelup.gitconnected.com/how-i-get-100-out-of-ai-when-coding-the-workflow-nobody-taught-me-b302b4aaf21d#bypass)