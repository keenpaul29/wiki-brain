---
title: "Enhance productivity with AI + Remote Dev"
source: "https://code.visualstudio.com/blogs/2025/05/27/ai-and-remote?ref=dailydev"
author:
  - "[[Microsoft]]"
published: 2021-11-03
created: 2026-05-08
description: "Enhance your developer productivity with AI and Remote Development."
tags:
  - "clippings"
---
[Build and test web apps with the integrated browser and AI agents.](https://code.visualstudio.com/docs/copilot/guides/browser-agent-testing-guide?source=vsc-website-banner)

May 27th, 2025 by [Brigit Murtaugh](https://github.com/bamurtaugh), [Christof Marti](https://github.com/chrmarti), [Josh Spicer](https://github.com/joshspicer), [Olivia Guzzardo McVicker](https://github.com/olguzzar)

One of the features that makes VS Code so flexible and powerful is [Remote Development](https://code.visualstudio.com/docs/remote/remote-overview). Whether you're connecting to a secure VM from your local desktop, a hugely powerful computer from your tablet, or a containerized environment with all the dependencies your project needs – VS Code's ability to develop *anything from anywhere* can help in just about any setup.

Now combine those capabilities with the flexibility and power of AI in VS Code, and you have an incredibly versatile dev environment. You can ensure chat conversations have context about your remote workspace, get AI help in setting up and debugging remote connections, and provide a more isolated space for agent mode to work autonomously.

In this blog, we'll explore how your existing remote setups can be enhanced to "just work" with AI, along with some more customized AI + remote workflows that include custom instructions, chat participants, and agent auto-approvals.

## What is Remote Development?

When we describe VS Code Remote Development, we refer to five main experiences:

- [Remote - SSH](https://code.visualstudio.com/docs/remote/ssh) - Connect to any location by opening folders on a remote machine/VM using SSH.
- [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) - Work with a separate toolchain or container-based application inside (or mounted into) a container.
- [WSL](https://code.visualstudio.com/docs/remote/wsl) - Get a Linux-powered development experience in the Windows Subsystem for Linux.
- [Remote - Tunnels](https://code.visualstudio.com/docs/remote/tunnels) - Connect to a remote machine via a secure tunnel, without configuring SSH.
- [GitHub Codespaces](https://code.visualstudio.com/docs/remote/codespaces) - Remote environments that are managed for you.

![Remote architecture](https://code.visualstudio.com/assets/blogs/2025/05/27/architecture.png)

Remote architecture

## How can you use AI in a remote environment?

We want to make the AI coding experience in VS Code as seamless as possible, whether you're working on your local machine or connected to a remote environment. If you're already using GitHub Copilot locally, we'll automatically install it remotely. And GitHub Codespaces has it configured too!

While using AI in a remote environment will just work, there are additional AI features that can make your remote workflow even more powerful:

- Custom instructions - Tailor your AI experience for your remote environment
- Chat participants - Use chat to set up and troubleshoot your remote environment
- Tool approvals - Run autonomous coding sessions safely in remote environments

## Tailor your AI experience for your remote environment

One of the top requests we hear from users when working with an LLM is: How can I help the LLM better understand my code and coding practices? You can achieve this via **custom instructions**, which describe common guidelines or rules to get responses that match your specific coding practices and tech stack. Instead of manually including this context in every AI chat query, custom instructions automatically incorporate this information with every chat request (learn more in our [recent blog post](https://code.visualstudio.com/blogs/2025/03/26/custom-instructions)).

In our team's recent self-hosting, we found it helpful to use custom instructions to not only tell Copilot about our code and coding practices, but to also provide more information about the type of remote environment we're connected to, such as:

- What kind of remote environment is this (i.e. a dev container vs a VM)?
- What languages or toolchains are installed? What's their purpose?
- Where are toolchains installed (i.e. are they available on the `PATH`)?

Here's an example instruction our team found helpful:

```markdown
This is a dev container that includes \`python3\` and \`pip3\` pre-installed and available on the \`PATH\`, along with the Python language extensions for Python development.
```

To get started with custom instructions in a remote environment, you can use the same [instruction files](https://code.visualstudio.com/docs/copilot/customization/overview) remotely that you were already using locally.

## Configure AI for your dev container

Dev containers make it easier to get started with a project by having all tools and dependencies preconfigured. By adding custom instructions, you can make sure that the LLM is tailored to that environment instead of providing generic answers. For example, a dev container for Python coding might have custom instructions about which tools are installed, or which coding guidelines to follow (as shared in the example above).

Our team has taken steps to preconfigure custom instructions to make your life even easier when using dev containers. We publish dev container resources (like images and Features) to ease the process of creating and connecting to dev containers, and we now include custom instructions in these files. Here’s an example of how you can use the custom dev container instructions our team added:

- Create a new dev container configuration using one of our images or Features. You could do this by hand, or via the **Dev Containers: Add Dev Container Configuration Files...** command supplied by the [Dev Containers extension](https://marketplace.visualstudio.com/search?term=dev%20containers&target=VSCode&category=All%20categories&sortBy=Relevance):
	![Dev Containers: Add Dev Container Configuration Files command in VS Code Command Palette](https://code.visualstudio.com/assets/blogs/2025/05/27/add-dev-container-config-command.png)
	Dev Containers: Add Dev Container Configuration Files command in VS Code Command Palette
- Follow the steps in the quick pick. For this example, we'll select the Python Template:
	![Select Python 3 dev container config in VS Code Command Palette](https://code.visualstudio.com/assets/blogs/2025/05/27/python-container.png)
	Select Python 3 dev container config in VS Code Command Palette
- Build and connect to your dev container in VS Code:
	![VS Code notification to reopen project in dev container](https://code.visualstudio.com/assets/blogs/2025/05/27/reopen-container-notif.png)
	VS Code notification to reopen project in dev container
- The environment you've selected and are now connected to is based on [our Python Template](https://github.com/devcontainers/templates/tree/main/src/python), which [includes custom instructions via the Python Feature](https://github.com/devcontainers/features/blob/main/src/python/devcontainer-feature.json#L80). Try chatting with Copilot within your dev container - Copilot automatically pulls the custom instructions from the Python image!
	![AI chat using custom instructions](https://code.visualstudio.com/assets/blogs/2025/05/27/chat-using-instructions.png)
	AI chat using custom instructions

In addition to using the custom instructions we've added to images and Features, you can add additional custom instructions to the `devcontainer.json` in your projects - we've made it so that custom instructions can merge successfully across images and Templates. You can use the `"github.copilot.chat.codeGeneration.instructions"` setting, just like what we did in the Python dev container config described above.

If you [publish](https://containers.dev/collections) any dev container configurations for others to use, we recommend exploring how you might add custom instructions to them! [Here](https://github.com/devcontainers/features/blob/main/src/python/devcontainer-feature.json#L80) is an example of using custom instructions in a Python dev container Feature:

```json
"github.copilot.chat.codeGeneration.instructions": [
    {
        "text": "This dev container includes \`python3\` and \`pip3\` pre-           installed and available on the \`PATH\`, along with the Python              language extensions for Python development."
    }
],
```

## Use chat to set up and troubleshoot your remote environment

*Chat participants* enhance your chat experience by providing domain-specific knowledge, such as how to interact with a database or a specific API. Type `@` in the chat input field to view and select from the list of available participants - they'll be available in Ask mode. There are several built-in chat participants like `@workspace`, `@vscode`, and `@terminal`. Extensions can also contribute chat participants.

The Remote - SSH extension includes a Copilot chat participant. Ask `@remote-ssh` for help configuring or troubleshooting elements of your remote environment:

![Using Remote - SSH participant in VS Code chat panel](https://code.visualstudio.com/assets/blogs/2025/05/27/remote-ssh-intro.png)

Using Remote - SSH participant in VS Code chat panel

The participant is also knowledgeable about general SSH and remote development topics:

![Asking Remote - SSH participant about remote auth](https://code.visualstudio.com/assets/blogs/2025/05/27/remote-ssh-auth.png)

Asking Remote - SSH participant about remote auth

If a connection failure occurs, the **Diagnose with Copilot** feature provides a quick way to understand the problem:

![Diagnose with Copilot option in notification](https://code.visualstudio.com/assets/blogs/2025/05/27/ssh-diagnose.png)

Diagnose with Copilot option in notification

Copilot will investigate the issue and provide actionable insights:

<video src="https://code.visualstudio.com/assets/blogs/2025/05/27/analyzing.mp4" title="Copilot diagnosing connection issue" controls=""></video>

## Run autonomous coding sessions safely in remote environments

As part of completing the tasks for a user prompt, [agent mode](https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode) can run tools and terminal commands. Agent mode is powerful because it not only proposes code changes but can also run terminal commands and tools. For example, it can install project dependencies or run tests. However, some of these actions might be destructive, such as deleting files, modifying local configuration, and more. Therefore, you need to approve the use of tools and terminal commands in agent mode.

![Agent mode tool approval options dropdown](https://code.visualstudio.com/assets/blogs/2025/05/27/chat-tool-approval.png)

Agent mode tool approval options dropdown

In case you want to auto-approve *all* tools, you can now use the experimental `chat.tools.autoApprove` setting. To give you some level of protection against inadvertent terminal commands or tool calls, you can choose to only set this in a dev container or remote machine to prevent your local dev machine from getting affected:

![Auto Approve tool setting in VS Code remote settings](https://code.visualstudio.com/assets/blogs/2025/05/27/auto-approval.png)

Auto Approve tool setting in VS Code remote settings

This will auto-approve all tools, and VS Code will not ask for confirmation when a language model wishes to run tools. This can help save time by giving more autonomy to agent mode, but bear in mind that with this setting enabled, you will not have the opportunity to cancel potentially destructive actions a model wants to take.

Note that remote environments that are part of your local machine (like dev containers) or that have access to your credentials will pose different levels of risk.

## What's Next

We're excited about the future of Remote Development and AI in VS Code. Our monthly releases are packed with exciting new features, and we're constantly looking ahead to what's next, like supporting Copilot Chat [in the web](https://code.visualstudio.com/docs/setup/vscode-web) ([vscode.dev](http://vscode.dev/microsoft/vscode), [github.dev](http://github.dev/microsoft/vscode)).

Happy (smart and remote) coding! Brigit, Christof, Josh, and Olivia
