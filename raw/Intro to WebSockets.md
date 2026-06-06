---
title: "Intro to WebSockets"
source: "https://thecodinggopher.substack.com/p/a-deep-dive-into-websockets?utm_source=substack&utm_medium=email&utm_content=share"
author:
  - "[[The Coding Gopher]]"
published: 2026-02-28
created: 2026-06-05
description: "The Persistent Conversation"
tags:
  - "clippings"
---
In the early days of the web, the internet was a formal, polite place. Your browser would request a page, the server would deliver it, and they would promptly hang up on each other. This is the **Request-Response** cycle of HTTP—a model that works perfectly for reading news or buying a book, but falls apart when the digital world needs to move at the speed of thought.

![What are WebSockets and Why are they Used?](https://substackcdn.com/image/fetch/$s_!gzTh!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Ff23533d6-ece5-4f0e-8c38-31f8b36d16b8_1540x590.png)

What are WebSockets and Why are they Used?

Enter **WebSockets**: the technology that transformed the web from a series of static snapshots into a living, breathing, real-time experience.

---

## The “Polling” Problem. Asking “Are We There Yet?”

Before WebSockets became a standard, developers had to “fake” real-time updates. The most common technique was **Short Polling**, where the browser would ping the server every few seconds to see if anything had changed.

![Understand and Implement Long-Polling and Short Polling in Node.js | by  Poorshad Shaddel | Level Up Coding](https://substackcdn.com/image/fetch/$s_!nP82!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F34ad9423-f6e6-496e-abbc-6c2bfce284d3_1200x843.png)

Understand and Implement Long-Polling and Short Polling in Node.js | by Poorshad Shaddel | Level Up Coding

Imagine sitting in a car and asking, “Are we there yet?” every five seconds. It’s exhausting for you (the client) and annoying for the driver (the server). In technical terms, this created massive **overhead**. Every single “Are we there yet?” required a full HTTP header—hundreds of bytes of metadata—just to receive a “No” in response.

![Exploring Short Polling, Long Polling, Server-Sent Events, and WebSockets |  by Atakan Demircioğlu | JavaScript in Plain English](https://substackcdn.com/image/fetch/$s_!7QkW!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F2dbaeceb-b837-4959-81a4-a11908740961_800x461.jpeg)

Exploring Short Polling, Long Polling, Server-Sent Events, and WebSockets | by Atakan Demircioğlu | JavaScript in Plain English

Then came **Long Polling**, a slightly more sophisticated hack where the server would hold the request open until it actually had news to share. While more efficient, it still required re-establishing a connection every time data was finally delivered. The web was begging for a permanent “open line.”

![What are WebSockets and Why are they Used?](https://substackcdn.com/image/fetch/$s_!buVw!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd7b11366-1a69-4e7a-8b80-b4e695aaa158_922x958.png)

What are WebSockets and Why are they Used?

## The WebSocket Handshake. Upgrading the Conversation

The genius of the WebSocket protocol (defined as **RFC 6455**) is that it doesn’t reinvent the wheel; it upgrades it. A WebSocket connection begins as a standard HTTP request, ensuring it can pass through most firewalls and proxies without being blocked.

The process follows a specific dance:

1. **The Request.** The client sends an HTTP GET request with a special header: `Upgrade: websocket`.
2. **The Agreement.** If the server speaks WebSocket, it responds with a `101 Switching Protocols` status code.
	![WebSockets Demystified, Part 1: Understanding the Protocol | by Damiano  Magrini | Level Up Coding](https://substackcdn.com/image/fetch/$s_!w7kT!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F9c68a94d-2418-4914-9bdb-6ad067a2173b_1400x1050.png)
	WebSockets Demystified, Part 1: Understanding the Protocol | by Damiano Magrini | Level Up Coding
3. **The Transformation:** At that moment, the “handshake” is complete. The HTTP protocol is discarded, and the underlying TCP connection is repurposed into a **persistent, bi-directional tunnel**.

![Understanding WebSockets with Socket.io | TO THE NEW Blog](https://substackcdn.com/image/fetch/$s_!Dms8!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fc6162e1c-a1a7-4525-91a0-3966a2078c55_783x607.png)

Understanding WebSockets with Socket.io | TO THE NEW Blog

*𝐋𝐞𝐚𝐫𝐧 𝐭𝐨 𝐛𝐮𝐢𝐥𝐝 𝐆𝐢𝐭, 𝐃𝐨𝐜𝐤𝐞𝐫, 𝐑𝐞𝐝𝐢𝐬, 𝐇𝐓𝐓𝐏 𝐬𝐞𝐫𝐯𝐞𝐫𝐬, 𝐚𝐧𝐝 𝐜𝐨𝐦𝐩𝐢𝐥𝐞𝐫𝐬, 𝐟𝐫𝐨𝐦 𝐬𝐜𝐫𝐚𝐭𝐜𝐡. Get 40% OFF CodeCrafters: [https://app.codecrafters.io/join?via=the-coding-gopher](https://app.codecrafters.io/join?via=the-coding-gopher)*

### Characteristics

- **Full-Duplex.** Unlike HTTP, where only one side can “talk” at a time, WebSockets allow the client and server to send data simultaneously.

![What is websocket ?](https://substackcdn.com/image/fetch/$s_!QWUT!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fb25c8a79-b61b-4cd8-8fd9-c8ebb85318bd_1200x548.png)

What is websocket?

- **Minimal Framing.** Once the connection is open, the metadata required to send a message drops from several hundred bytes to as little as **2 bytes**. This is the difference between sending a formal letter in an envelope and sending a quick text message.
- **Stateful.** The server knows exactly who you are without you having to send a session cookie or authentication token with every single packet of data. The “context” of the conversation is preserved.

![Introduction to Websockets. - NashTech Blog](https://substackcdn.com/image/fetch/$s_!57fh!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F4d233a52-3cb0-4566-93cb-70cd5614ed90_628x511.png)

Introduction to Websockets. - NashTech Blog

---

## When Real-Time is Non-Negotiable

WebSockets are the engine under the hood of the modern interactive web. If you see a “typing...” indicator in a chat app, or a stock price flickering red and green, you are likely looking at a WebSocket in action.

### Primary Use Cases

- **Collaborative Tools.** Platforms like Google Docs or Figma rely on WebSockets to sync cursor movements and keystrokes across thousands of miles in milliseconds.
- **Financial Ecosystems.** High-frequency trading and crypto tickers require updates the instant a trade occurs. A delay of 200ms isn’t just a nuisance; it’s a financial loss.
- **Gaming.** Multiplayer web games require instantaneous synchronization of player positions and actions to ensure the “game state” is identical for everyone.
- **Live Sports & Media.** Score updates and live commentary that push to your screen the second a goal is scored, often beating the delay of a digital cable broadcast.

---

## The Operational Trade-Offs

While WebSockets sound like the ultimate solution, they come with a “tax” on infrastructure. Because the connection stays open, it consumes **server memory (RAM)**.

A traditional web server can handle a million “passing through” HTTP requests because it forgets about the user the moment the page is sent. However, maintaining a million active “phone calls” requires significant infrastructure. Developers must implement **Heartbeats** (Ping/Pong frames) to ensure the connection hasn’t died silently, and they must handle complex **Load Balancing** to ensure a user stays connected to the same server or that the servers can share the state.

Additionally, WebSockets don’t handle **caching** well. Browsers can’t “save” a WebSocket response the way they can a JPEG or an HTML file, making them unsuitable for static content.

---

## The Future. WebSockets vs. HTTP/3 and WebTransport

As we move into 2026 and beyond, the landscape is shifting. While WebSockets remain the gold standard, newer technologies like **WebTransport** (built on top of HTTP/3 and QUIC) are beginning to emerge.

WebTransport offers even faster speeds by using UDP instead of TCP, avoiding “Head-of-Line Blocking”—a technical hiccup where one lost packet of data can delay all the packets behind it. However, for the vast majority of real-time needs, the WebSocket remains the most reliable, widely supported, and battle-tested tool in a developer’s kit.