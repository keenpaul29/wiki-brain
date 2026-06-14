---
title: "HLD Fundamentals #1: Network Protocols"
source: "https://dev.to/jaspreet_singh_86ae1740ac/hld-fundamentals-1-network-protocols-171p"
author:
  - "[[Jaspreet singh]]"
published: 2026-06-14
created: 2026-06-14
description: "Network Protocols   Network protocols define how computers communicate over a... Tagged with beginners, computerscience, networking, systemdesign."
tags:
  - "clippings"
---
## Network Protocols

Network protocols define how computers communicate over a network.

Whether you're opening Instagram, sending a WhatsApp message, watching Netflix, or transferring money through a banking app, some protocol is working behind the scenes to make communication possible.

---

## Client-Server Model

## What is it?

The Client-Server model is a communication architecture where:

- **Client** requests a service or data.
- **Server** processes the request and returns a response.

Most modern applications follow this architecture.

---

## How Does It Work?

```
Client  ---------- Request ---------->  Server

Client  <--------- Response ----------  Server
```

The client always initiates communication, and the server listens for incoming requests.

---

## Real World Example

### Instagram

When you open Instagram:

1. Mobile app sends a request.
2. Instagram servers process the request.
3. Feed data is fetched from databases.
4. Posts are returned to your phone.
```
Instagram App
      |
      V
Instagram Server
      |
      V
Database
```

---

## Advantages

- Centralized control
- Easier security management
- Easy maintenance
- Easier data consistency

---

## Disadvantages

- Server can become a bottleneck
- Single point of failure if not replicated

---

## Interview One-Liner

Client-Server architecture is a centralized model where clients request resources and servers provide them.

---

## Peer-to-Peer (P2P) Model

## What is it?

In a Peer-to-Peer network, every machine can act as both:

- Client
- Server

There is no central server controlling communication.

---

## How Does It Work?

```
Peer A <------> Peer B
   ^               ^
   |               |
   V               V
Peer C <------> Peer D
```

Each peer can directly share resources with others.

---

## Real World Example

### BitTorrent

Instead of downloading a file from one server:

```
User
 |
 +--> Peer 1
 |
 +--> Peer 2
 |
 +--> Peer 3
```

Different parts of the file are downloaded from multiple peers simultaneously.

### Blockchain

Bitcoin and Ethereum networks operate using Peer-to-Peer communication.

---

## Advantages

- Highly scalable
- No central server cost
- Better fault tolerance

---

## Disadvantages

- Harder to manage
- Security challenges
- Data consistency issues

---

## Interview One-Liner

Peer-to-Peer architecture allows nodes to communicate directly without relying on a centralized server.

---

## WebSockets

## What is it?

WebSocket is a protocol that creates a persistent, two-way communication channel between a client and a server.

Unlike HTTP, the connection remains open.

---

## Why Do We Need It?

With HTTP:

```
Request
Response
Connection Closed
```

The server cannot push data later unless the client sends another request.

WebSockets solve this problem.

---

## How Does It Work?

```
Client <===================> Server

      Persistent Connection
```

Once connected:

- Client can send messages anytime.
- Server can send messages anytime.

This is called **Full Duplex Communication**.

---

## Real World Example

### WhatsApp

```
You ------> Server ------> Friend
```

When your friend sends a message, the server immediately pushes it to your device.

No page refresh is required.

### Other Examples

- Live Chat Applications
- Multiplayer Games
- Trading Platforms
- Live Sports Scores

---

## Advantages

- Real-time communication
- Low latency
- Fewer network requests

---

## Interview One-Liner

WebSockets provide a persistent bidirectional connection that enables real-time communication between client and server.

---

## HTTP

## What is HTTP?

HTTP (HyperText Transfer Protocol) is the protocol used for communication between web clients and servers.

It follows a request-response model.

---

## How Does It Work?

```
Browser/App
      |
 HTTP Request
      |
      V
Server
      |
HTTP Response
      |
      V
Browser/App
```

HTTP typically runs on top of TCP.

---

## Common Methods

| Method | Purpose |
| --- | --- |
| GET | Read Data |
| POST | Create Data |
| PUT | Update Data |
| DELETE | Remove Data |

---

## Real World Example

### Amazon

When you search for a product:

1. Browser sends HTTP request.
2. Amazon server processes it.
3. Matching products are returned.

---

## Key Points

- Stateless protocol
- Request-response communication
- Runs over TCP
- Foundation of web applications

---

## Interview One-Liner

HTTP is an application-layer protocol used for communication between clients and web servers.

---

## TCP

## What is TCP?

TCP (Transmission Control Protocol) is a transport-layer protocol that guarantees reliable and ordered delivery of data.

If a packet is lost, TCP retransmits it.

---

## How Does It Work?

Before communication begins, TCP establishes a connection using a 3-way handshake.

```
Client ---- SYN ----> Server

Client <-- SYN-ACK -- Server

Client ---- ACK ----> Server
```

Connection established.

---

## Real World Example

### Banking Applications

When transferring money:

- Data must not be lost.
- Packets must arrive in order.
- Reliability is critical.

TCP ensures all of this.

---

## Advantages

- Reliable delivery
- Ordered packets
- Error checking

---

## Disadvantages

- Higher latency
- Additional overhead

---

## Interview One-Liner

TCP is a reliable transport protocol that guarantees ordered and error-free data delivery.

---

## UDP

## What is UDP?

UDP (User Datagram Protocol) is a transport-layer protocol focused on speed rather than reliability.

It sends packets without waiting for acknowledgements.

---

## How Does It Work?

```
Send Packet
Send Packet
Send Packet
```

No confirmation.  
No retransmission.

---

## Real World Example

### Online Gaming

Games like PUBG and BGMI send player position updates continuously.

If one update is lost, the next update arrives quickly.

Waiting for retransmission would increase lag.

### Other Examples

- Video Calls
- Live Streaming
- DNS Queries
- Gaming

---

## Advantages

- Very fast
- Low latency
- Minimal overhead

---

## Disadvantages

- No delivery guarantee
- No ordering guarantee

---

## Interview One-Liner

UDP is a lightweight transport protocol optimized for speed and low latency.

---

## FTP

## What is FTP?

FTP (File Transfer Protocol) is used to transfer files between computers over a network.

---

## How Does It Work?

```
FTP Client <------> FTP Server
```

Users can:

- Upload files
- Download files
- Delete files
- Rename files

---

## Real World Example

A developer uploads website files:

```
index.html
style.css
logo.png
```

to a production server using FTP.

---

## Interview One-Liner

FTP is a protocol specifically designed for transferring files over a network.

---

## SMTP

## What is SMTP?

SMTP (Simple Mail Transfer Protocol) is used for sending emails.

---

## How Does It Work?

```
Sender
   |
 SMTP
   |
Mail Server
   |
Recipient
```

SMTP handles only the sending part of email communication.

---

## Real World Example

When you click "Send" in Gmail, SMTP is responsible for delivering that email.

---

## Interview One-Liner

SMTP is the standard protocol used for sending emails between mail servers.

---

## POP3

## What is POP3?

POP3 (Post Office Protocol v3) is used to receive emails.

It downloads emails from the server to your local device.

---

## How Does It Work?

```
Mail Server
      |
 Download
      |
Laptop/Desktop
```

Traditionally, emails were removed from the server after download.

---

## Advantages

- Works offline
- Less server storage required

---

## Disadvantages

- Poor synchronization across devices

---

## Interview One-Liner

POP3 retrieves emails by downloading them from the mail server to a local device.

---

## IMAP

## What is IMAP?

IMAP (Internet Message Access Protocol) is used to receive emails while keeping them stored on the server.

---

## How Does It Work?

```
Phone
   |
Mail Server
   |
Laptop
```

Changes made on one device are synchronized across all devices.

---

## Real World Example

Read an email on your phone and it automatically appears as read on your laptop.

This is IMAP in action.

---

## Advantages

- Multi-device synchronization
- Emails remain on server
- Better user experience

---

## Disadvantages

- Requires more server storage

---

## Interview One-Liner

IMAP allows email synchronization across multiple devices while keeping emails stored on the server.

---

## HTTP vs TCP vs UDP vs FTP vs SMTP

| Protocol | Layer | Purpose | Example |
| --- | --- | --- | --- |
| HTTP | Application | Web Communication | Amazon, Netflix |
| TCP | Transport | Reliable Communication | Banking |
| UDP | Transport | Fast Communication | Gaming |
| FTP | Application | File Transfer | Website Deployment |
| SMTP | Application | Sending Emails | Gmail |
| POP3 | Application | Download Emails | Legacy Mail Clients |
| IMAP | Application | Sync Emails | Gmail, Outlook |

---

## Quick Revision

### Client-Server

Instagram, Netflix, Amazon

```
Client -> Request
Server -> Response
```

### Peer-to-Peer

BitTorrent, Blockchain

```
Peer <-> Peer
```

### WebSockets

WhatsApp, Live Chat

```
Persistent Two-Way Connection
```

### TCP

Reliable + Ordered

### UDP

Fast + Low Latency

### HTTP

Web Communication

### FTP

File Transfer

### SMTP

Send Emails

### POP3

Download Emails

### IMAP

Sync Emails

---

## Interview Summary

Most modern applications use the Client-Server model where communication happens using HTTP over TCP. For real-time applications like WhatsApp, WebSockets maintain a persistent connection. TCP is chosen when reliability is important, while UDP is preferred when speed and low latency matter. FTP is used for file transfers, SMTP is used for sending emails, and IMAP/POP3 are used for receiving emails.[AWS](https://dev.to/aws)Promoted

[![Promotional image](https://media2.dev.to/dynamic/image/width=775%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fi.imgur.com%2FxXlUArJ.jpeg)](https://aws.amazon.com/products/developer-tools/agent-toolkit-for-aws/?utm_source=devto&utm_medium=display&utm_campaign=agenttoolkit&bb=263683)

## Your AI agent makes the same AWS mistakes every time. We made a list.

Over-broad IAM, the wrong service for the job, patterns that aged out years ago. You've watched your agent make the same AWS mistakes again and again, then fixed them yourself.

The Agent Toolkit for AWS ships skills built around those exact failure points, so the answer you get back is one you can ship. One install, in the tool you already use.