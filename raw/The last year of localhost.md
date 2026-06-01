---
title: "The last year of localhost"
source: "https://ona.com/stories/the-last-year-of-localhost"
author:
  - "[[Ona Team]]"
published: 2026-02-13
created: 2026-05-27
description: "Background agents humming across a software assembly line can't run on a laptop."
tags:
  - "clippings"
---
Background agents humming across a software assembly line can't run on a laptop.

Stripe's Minions [merge over a thousand agent-authored pull requests](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents) per week. Ramp's background agent accounts for [57% of all merged PRs](https://builders.ramp.com/post/why-we-built-our-background-agent). Last week, [Ona authored 88.5% of the PRs we merged on main.](https://x.com/jolandgraf/status/2021014978367717769?s=20)

What these teams share isn't a special agent harness or a smarter model. They standardized their development environments years ago. Stripe had cloud-based devboxes before GPT-3 existed. Those investments predated the agent era by years, and now they're paying compound returns.

What's blocking your team is what has been broken all along: your development environment.

## The end of localhost

We started Gitpod (now Ona) five years ago to move software development to the cloud. To do for dev what Figma did for design. We set out to solve the 'works on my machine' problem: dev environments drift out of sync with production, with CI, with each other. Every team has slightly different setups. Onboarding takes days, sometimes months. Debugging local environment issues is a full-time job for some platform engineers. We believed the answer was cloud development environments, and we said it over and over.

Between 2020–2022 it felt like we were right. [Swyx agreed, Hacker News didn't](https://news.ycombinator.com/item?id=31669762). Then it felt like we were too early.

" [The year of the cloud development environment](https://redmonk.com/jgovernor/the-year-of-the-cloud-development-environment/) " was becoming the new "year of the Linux desktop": always right in theory, never in practice.

Cloud development environments solve real problems: environment drift, onboarding time, reproducibility. But for most developers, local setups were good enough. Apple's M1 closed the performance gap, and the pull of "just use my laptop" was strong: zero latency, years of customization, a workflow that felt like identity. The case for CDEs was real, but never urgent enough to force a move.

As with so many things, AI changed that. Fleets of agents humming across a software assembly line don't fit on a laptop. Each agent needs its own isolated, fully provisioned environment with access to internal services and production-grade toolchains. Development is finally moving to the cloud, for a reason nobody originally expected.

This time for real: with four years of delay, [localhost is going to end](https://news.ycombinator.com/item?id=31669762).

## Cloud development environments are a prerequisite for agents

Look at the companies leading the background agent wave and trace their dev infrastructure history.

Stripe built its remote development environment years ago. [As Soam Vasani described](https://www.infoq.com/presentations/stripe-dev-env-infrastructure/), every Stripe engineer gets an EC2 devbox with a Sorbet server, full monorepo checkout, and rsync from their laptop. Standardized, reproducible, managed centrally. When Stripe built Minions, their one-shot coding agent, they didn't need to figure out where the agent runs. The answer already existed: the same environment every engineer uses. Same dependencies, same test suite, same credentials and network access. That's how they went from prototype to thousands of merged PRs per week in months. The agent infrastructure was a thin layer on top of years of environment investment.

Ramp followed a similar path, [building their own background agent](https://builders.ramp.com/post/why-we-built-our-background-agent) on standardized environments and running it across their codebase. Same pattern: environment standardization first, agents on top.

[<svg viewBox="50 0 900 240" overflow="hidden"><rect x="0" y="0" width="1000" height="240" fill="transparent"></rect><path d="M 0 80 L 380 80 C 460 80, 460 80.35017032217303, 500 80.35017032217303 C 540 80.35017032217303, 540 80, 620 80 L 1000 80 L 1000 220 L 620 220 C 540 220, 540 219.64982967782697, 500 219.64982967782697 C 460 219.64982967782697, 460 220, 380 220 L 0 220 Z" fill="#FFFFFF" opacity="0.45"></path><path d="M 0 80 L 380 80 C 460 80, 460 80.35017032217303, 500 80.35017032217303 C 540 80.35017032217303, 540 80, 620 80 L 1000 80" fill="none" stroke="#D0D0D0" stroke-width="1.5"></path><path d="M 0 220 L 380 220 C 460 220, 460 219.64982967782697, 500 219.64982967782697 C 540 219.64982967782697, 540 220, 620 220 L 1000 220" fill="none" stroke="#D0D0D0" stroke-width="1.5"></path><text x="60" y="30" text-anchor="middle" font-family="&quot;ABC Diatype&quot;, system-ui, sans-serif" font-size="13" font-weight="600" letter-spacing="0.1em" fill="#666666">PLAN</text> <line x1="60" y1="40" x2="60" y2="75" stroke="#CCCCCC" stroke-width="1" stroke-dasharray="3,3"></line><text x="280" y="30" text-anchor="middle" font-family="&quot;ABC Diatype&quot;, system-ui, sans-serif" font-size="13" font-weight="600" letter-spacing="0.1em" fill="#666666">CODE</text> <line x1="280" y1="40" x2="280" y2="75" stroke="#CCCCCC" stroke-width="1" stroke-dasharray="3,3"></line><text x="500" y="30" text-anchor="middle" font-family="&quot;ABC Diatype&quot;, system-ui, sans-serif" font-size="13" font-weight="600" letter-spacing="0.1em" fill="#666666">REVIEW</text> <line x1="500" y1="40" x2="500" y2="75" stroke="#CCCCCC" stroke-width="1" stroke-dasharray="3,3"></line><text x="720" y="30" text-anchor="middle" font-family="&quot;ABC Diatype&quot;, system-ui, sans-serif" font-size="13" font-weight="600" letter-spacing="0.1em" fill="#666666">TEST</text> <line x1="720" y1="40" x2="720" y2="75" stroke="#CCCCCC" stroke-width="1" stroke-dasharray="3,3"></line><text x="940" y="30" text-anchor="middle" font-family="&quot;ABC Diatype&quot;, system-ui, sans-serif" font-size="13" font-weight="600" letter-spacing="0.1em" fill="#666666">DEPLOY</text><line x1="940" y1="40" x2="940" y2="75" stroke="#CCCCCC" stroke-width="1" stroke-dasharray="3,3"></line><circle cx="981.0390931747655" cy="155.74584629726775" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="943.0574350482641" cy="164.0267718203423" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="903.9960256933963" cy="163.9330408631697" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="891.804355886199" cy="163.66340428605628" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="886.2038180513932" cy="143.25956499259559" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="883.8044943905804" cy="149.29131692334823" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="882.0877025910843" cy="142.18974153203007" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="880.3944805977095" cy="151.54790281279492" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="879.290117278066" cy="140.96773225434916" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="874.5967581231545" cy="150.359086503808" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="869.1340332524411" cy="141.0665505237316" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="846.3770432033601" cy="158.24011243499743" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="843.7451902400323" cy="135.52074657643178" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="815.7890156518421" cy="161.49055707651848" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="785.6857361362663" cy="158.4646958882322" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="766.2370454798651" cy="141.40591889014843" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="729.7504437545125" cy="146.31423888341382" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="693.5099255772997" cy="146.89512596292343" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="653.9209585196287" cy="139.20149652357307" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="643.3775370756331" cy="163.91126170669705" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="632.8275453873001" cy="137.08279143990123" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="617.6022388039537" cy="138.75116588565479" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="611.2498618067067" cy="151.2767153805969" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="599.3030630903271" cy="158.2474522667531" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="591.5161186143893" cy="163.96476066769645" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="567.2063034984125" cy="135.58711871160074" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="542.8243176495499" cy="153.31186668423928" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="506.02625994301326" cy="138.2766859566357" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="497.3516084183018" cy="164.63650493358745" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="493.97157222690856" cy="158.1672052135831" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="491.11057835248135" cy="137.43586354009375" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="489.46363743550916" cy="142.34685258220247" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="485.7159376248235" cy="154.05354800496403" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="484.2655049265311" cy="148.1952349672008" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="479.8382395192852" cy="157.95648455199222" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="478.8145541352892" cy="154.02552974717588" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="477.1019223281147" cy="152.7385182743515" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="478.0495090900884" cy="147.5469254868876" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="475.52889026970377" cy="142.0480436146975" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="473.6792712560979" cy="149.6753949694298" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="470.72068228225834" cy="135.71729926966376" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="468.9103709095928" cy="152.76363022134487" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="465.2632417827034" cy="156.23347890232642" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="450.3219182061132" cy="146.28631748926793" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="361.60751986862016" cy="147.3468518645841" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="276.29629046998235" cy="155.98435703702026" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="242.4446868561969" cy="154.8152110278642" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="205.17671982718753" cy="140.06075792185783" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="170.65392213073883" cy="145.48497995351153" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="134.8699853719269" cy="156.13123231333483" r="5" fill="#1A4A6E" opacity="0.8"></circle><circle cx="101.10741328380924" cy="154.79534445995975" r="5" fill="#C41E3A" opacity="0.8"></circle><circle cx="65.80942158636414" cy="161.84939108164912" r="5" fill="#8B4513" opacity="0.8"></circle><circle cx="29.048635182445143" cy="140.3805110353422" r="5" fill="#2E5A1C" opacity="0.8"></circle><circle cx="4.0866188570422" cy="161.44363332452474" r="5" fill="#1A4A6E" opacity="0.8"></circle></svg>

Background agentsA visual guide to background agentsExplore

](https://background-agents.com/)

The inverse is equally telling. We talk to teams that have already wired agents to their issue trackers, automatically assigning tickets and generating code. The agent can read the codebase, maybe even compile it. But it can't run the application, execute tests against real services, or validate its own work. It produces code that looks right but hasn't been tested.

The gap between "generates a diff" and "opens a merge-ready PR" is the development environment.

The companies moving fastest on agents already have a standardized, reproducible environment layer. Everyone else is discovering they need to build one first. Done right, this is a major infrastructure project before you even deploy your first agent at scale, let alone manage day-two operations.

## Why git worktrees break and localhost can't do what agents need

If you're a developer productivity engineer at a company with a monorepo, tasked by your frenetic CEO to get to the same % of PRs merged by background agents as Ramp, you've probably started with git worktrees. You want to run three agents in parallel, so you create three git worktrees. Each worktree gets its own branch, its own checkout, its own agent.

In a monorepo, this breaks immediately.

Each worktree needs its own dependency install, its own running services, its own database instance. The filesystem is shared but the runtime state is not. You end up with port conflicts, shared caches corrupting each other, and a machine that grinds to a halt. We hear this constantly from teams: three worktrees running simultaneously and the laptop becomes unusable.

The problem is amplified by what monorepo environment setup looks like. It's not "clone and run." It's install 15 tools, configure 3 databases, seed test data, start 8 services, wait for compilation. At some companies, setting up a local dev environment from scratch takes days. Doing this once is painful. Doing it 5 times in parallel on a laptop is impossible.

There's an organizational issue on top of this. Most companies have no standardized approach to running agents. Individual developers are experimenting with different tools, different setups, different workarounds. Some run agents in CI. Some try local worktrees. Some use GitHub Actions. There is no shared foundation, which means every team rediscovers the same limitations independently and your organisation doesn't get the productivity lift that your board mandates.

Agents need many environments doing many things simultaneously. This is a fundamentally different workload shape, and no amount of local hardware will solve it. You can't buy a laptop big enough to run five full monorepo environments in parallel.

## What we built (and what we got wrong along the way)

We've spent five years learning what a cloud development environment needs to serve both human engineers and autonomous agents. Some of those lessons came from getting it right. Many came from getting it wrong. [For example to not rely on Kubernetes.](https://ona.com/stories/we-are-leaving-kubernetes)

But rather than cataloging which infrastructure primitives fail (we've [written about that elsewhere](https://ona.com/stories/dont-build-a-coding-agent-sandbox)), I want to focus on what works. What properties does a cloud development environment need to serve both human engineers and autonomous agents?

### Isolation: VMs, not containers

Agents run arbitrary code, so the security boundary matters. Containers share a kernel with the host and a container escape gives an attacker access to every other container on the same machine: other agents, other users, other customers. Human attackers are slow and often unskilled; agents are tenacious, skillful and knowledgeable.

The right primitive is a virtual machine. Each environment gets its own kernel, memory space, and network stack. An agent compromising a VM cannot reach other environments. At Ona, every environment runs in its own VM. It's the only security boundary that holds when the tenant is an autonomous agent executing untrusted code.

### Declarative, reproducible environment definition

The [Dev Container spec](https://containers.dev/) is the underappreciated hero of this story. A `devcontainer.json` codifies everything an environment needs: base image, language runtimes, tool versions, editor extensions, environment variables, port forwarding, lifecycle hooks. Given this file, any machine—a human's laptop, a cloud VM, or an agent sandbox—produces an identical environment.

Dev containers have a marketing problem. Most engineers think of them as "that VS Code remote container thing." The spec is actually an open standard that solves reproducibility at the config-as-code level, the closest thing the industry has to a universal environment definition format.

When we first tackled this at Gitpod, we created `.gitpod.yml`. Naming a spec after your company is a mistake. We were genuinely happy when Microsoft pushed the Dev Container spec as an open standard building on a lot of the core ideas of our `.gitpod.yml`. That validation mattered, and it's why we adopted Dev Containers as the foundation when we rewrote Gitpod's architecture from scratch in late 2023 to be AI-first. The industry needed a vendor-neutral way to define "what does this project need to run," and Dev Containers are that.

### Automated environment lifecycle

Reproducibility alone isn't enough. The environment also needs to set itself up without human intervention.

At Ona, we solve this with an `automations.yaml` file that defines two primitives: **services** (long-running processes like databases, dev servers, language servers) and **tasks** (one-time setup like dependency installation, code generation, database migration). Each has explicit triggers: run on environment start, on prebuild, or manually. An agent's environment boots, installs dependencies, starts all required services, seeds test data, and is ready to accept work. No manual steps.

What you need are clean-room environments reliable enough for autonomous operation. The automation layer is what turns a reproducible environment into a self-assembling one.

### Connectivity and context

An agent's output is proportional to the context quality it can access. An agent running in a third-party sandbox can read your code. An agent running inside your network can read your code, query your databases, hit your internal APIs, and run your full test suite against staging. When those environments run inside the company's own cloud account, an engineer can assign a single IAM role to the instance and immediately have access to everything relevant — no tunnels, no exported secrets, no proxy hacks.

Most agent sandboxes punt on this. They give you a container or microVM in someone else's cloud and tell you to figure out networking yourself oftentimes resulting in brittle setups that break constantly.

To maximize the output of background agents they need the complete development workflow: clone, branch, install, build, test, iterate, commit, push. SCM integration, build toolchains, test runners, linters, end-to-end execution. The difference between "a container with a shell" and "a development environment" is this full loop.

At Ona, environments live inside the customer's own VPC on AWS, GCP, and soon Azure with native network access to everything a developer would have, no tunneling required. When an agent opens a pull request, it has run the same tests, linters, and build process a human engineer would. We wrote about this in more detail in ["don't build a coding agent sandbox yourself"](https://ona.com/stories/dont-build-a-coding-agent-sandbox).

### Security: assume compromise, enforce at the kernel

Agents are not trusted users. They cannot be. Anyone who tells you they've "solved" prompt injection is selling something that doesn't exist.

The right question isn't "how do we prevent compromise?" it's "what can the agent reach and attempt to compromise?"

Ona's security operates at two layers. First, credentials: environments get short-lived, scoped tokens tied to organization, project, and user. Second, kernel-level enforcement. We monitor every system call, file access, network packet, and what agents execute in the kernel. A jailbroken agent hits a wall enforced by the operating system. Policy-as-code lets organizations define hard constraints — "no public S3 buckets," "no writes to production databases" — that override agent autonomy entirely.

We're writing more about our approach to agent runtime security soon, and I'm excited to share that [Leo](https://github.com/leodido) and [Lorenzo](https://github.com/fntlnz), creators of [Falco](https://falco.org/), have joined Ona.

![Veto — kernel-level enforcement engine](https://ona.com/_next/image?url=%2Fimages%2Fcontent%2Fsanity%2Fveto-cover-dark.png&w=3840&q=75&dpl=dpl_4FzfKL2JKB2pVDJ1gHkJsk4g7ic5)

Introducing Veto

## The compounding effect

Companies that standardized their environments now run agents in parallel, automate code review, clear backlogs overnight, and mass-refactor across hundreds of packages. Scheduled agents pick up tickets from issue trackers at 7am and have PRs ready by standup, already churning away the next task during meetings. Background agents triggered from error monitoring tools like Sentry triage and fix bugs without human initiation reducing noise and cloud bills. At Ona, we use this internally and it accelerated our engineering capacity in ways we didn't think possible.

The same infrastructure that makes an engineer productive on day one makes an agent productive on task one.

The impact extends beyond engineering. When a development environment is one click away, product managers, engineering managers and designers can access the codebase directly. A designer adjusting spacing can spin up an environment, have an agent make the change, and send a PR instead of pulling an engineer out of deep work for a trivial fix. Support teams can answer customer questions against actual source code. Onboarding a non-technical person to the local dev environment takes days of hand-holding, and the setup breaks the moment they stop maintaining it. A cloud environment that sets itself up eliminates that entirely, breaks silos and accelerates how you collaborate.

## What this means for your team

If you're evaluating background agents, start by auditing your dev environment standardization:

- Can a new engineer go from zero to running code in one-click under 10 minutes?
- Can you spin up 10 identical environments programmatically?
- Is your environment definition checked into your repo?
- Does your environment set itself up without manual steps?
- Can your environments reach all the internal services they need, securely?
- If an agent is compromised, what limits the blast radius? Are credentials ephemeral and cryptographically bound, or are they long-lived secrets sitting in environment variables?

If the answer to any of these is no, you will not get the lift that you expect from background agents. Regardless of how great model capability will be.

The investment in standardizing your development workflows pays dividends across human productivity, agent productivity, security posture, and onboarding. It's the foundation layer that everything else builds on.

We have been building this infrastructure for five years because we believed software development would move to the cloud.

With the arrival of background agents it's finally happening, through a different door than we expected.

We'd love to help you beat our 88.5% of merged PRs on main. The technology exists, [let's go](https://app.ona.com/)!

[![An engineering leader's guide to background agents](https://ona.com/_next/image?url=%2Fimages%2Fcontent%2Fsanity%2Fbackground-agents-guide-cover.webp&w=3840&q=75&dpl=dpl_4FzfKL2JKB2pVDJ1gHkJsk4g7ic5)

GuideAn engineering leader's guide to background agentsThis guide breaks down what leading companies built, what it cost them, and how Ona delivers the same five primitives in a managed platform.Read the guide

](https://ona.com/guides/background-agents)