---
title: "Netflix's CDN Strategy: Delivering Video to 300M Users Instantly"
source: "https://grindengineer.com/p/how-netflix-delivers-video-to-300-million-users-without-buffering"
author:
  - "[[Aditya Singh Sisodiya]]"
published: 2026-05-23
created: 2026-06-05
description: "Learn how Netflix delivers seamless 4K video to 300 million users globally by building its own CDN, keeping 95% of traffic off the cloud and placing servers directly inside ISPs."
tags:
  - "clippings"
---
## How Netflix Delivers Video to 300 Million Users Without Buffering

A deep dive into how Netflix built a global content delivery network from scratch

![How Netflix Delivers Video to 300 Million Users Without Buffering](https://media.beehiiv.com/cdn-cgi/image/fit=scale-down,quality=80,format=auto,width=720,onerror=redirect/uploads/asset/file/95472934-808b-4ee0-b537-92e8b1dbb1dd/netflix.png)

Netflix accounts for roughly **15% of all downstream internet traffic worldwide**. Every evening, hundreds of millions of people press play at the same time, and the video starts almost instantly. No buffering wheel. No pixelated frames. Just seamless 4K streaming.

Most people assume Netflix streams from "the cloud." They do not. **95% of Netflix's video traffic** never touches AWS or any traditional cloud infrastructure. It comes from servers that Netflix physically placed inside your internet service provider's building.

❝ 
Welcome to ***Grind Engineer***, your guide to becoming a better software engineer! No fluff. Pure engineering insights. 
❝

**Added High Paying Job Openings in the end!**

![](https://media.beehiiv.com/cdn-cgi/image/fit=scale-down,quality=80,format=auto,width=720,onerror=redirect/uploads/asset/file/11411331-db8b-4637-a82c-dec157985d80/image.png)

### Why Netflix Built Its Own CDN

In 2007, Netflix shipped DVDs. By 2011, streaming had exploded, and they were using third party CDNs like Akamai and Limelight to deliver video. The costs were enormous, the control was limited, and the quality was inconsistent across regions.

So they built **Open Connect**, their own purpose built Content Delivery Network. Not a general purpose CDN like Cloudflare or CloudFront. A CDN that does exactly one thing: deliver video bytes as fast as possible.

| Metric | Netflix Open Connect |
| --- | --- |
| Video traffic served | 95% of all Netflix streams |
| Server locations | Thousands of servers in 1,000+ ISP networks across 6 continents |
| Hardware cost to ISPs | Free (Netflix provides the servers at no charge) |
| Server OS | FreeBSD |
| Web server | NGINX |
| Storage per server | Up to 280 TB of SSD and HDD |

### How It Works: The Two Phase System

Netflix's CDN operates in two distinct phases that never overlap.

**Phase 1: Fill (off peak hours, typically 2 AM to 8 AM local time)**

During off peak hours, Netflix pushes video content from its AWS origin servers to Open Connect Appliances (OCAs) worldwide. This is predictive. Netflix uses machine learning models to determine which titles are most likely to be watched in each region tomorrow, and pre loads those onto the local servers.

A new show launching globally? The OCAs in Mumbai, Sao Paulo, London, and Tokyo already have it cached before a single user presses play.

**Phase 2: Serve (when you press play)**

When a user hits play:

1. The Netflix app contacts the **Playback Service** on AWS to get authorization and a streaming manifest
2. The Playback Service returns a list of OCA URLs ranked by proximity, health, and current load
3. The app connects directly to the best OCA and starts downloading video segments
4. If that OCA becomes overloaded or unreachable, the app seamlessly falls back to the next one

❝

💡 **Key Insight:** The Playback Service on AWS handles only the control plane (authentication, manifest, steering). The actual video bytes, the data plane, flow directly from the OCA inside your ISP to your device. This separation of control plane and data plane is one of the most important patterns in system design.

### The OCA: A Server Inside Your ISP

An **Open Connect Appliance** is a custom built server that Netflix designs, manufactures, and ships to ISPs worldwide. Netflix gives these servers to ISPs **for free**. Why would they do that?

Because it is a win for both sides:

| Netflix gets | ISP gets |
| --- | --- |
| Lower transit costs (no paying for cross continent bandwidth) | Reduced backbone traffic (Netflix data stays local) |
| Better streaming quality (lower latency, fewer hops) | Happier customers (faster streaming) |
| Full control over delivery stack | Free high performance hardware |

A single OCA can serve **40 Gbps of throughput**. A typical ISP deployment includes multiple OCAs, giving the ISP enough capacity to serve all Netflix traffic locally without any data leaving their network.

The hardware evolves constantly. Recent OCAs pack up to **280 TB of storage** using a mix of SSDs (for popular content) and HDDs (for the long tail catalog). The most requested titles sit in flash storage for sub millisecond access. The rest sits on spinning disks.

### Predictive Caching: How Netflix Knows What You'll Watch Tomorrow

With a catalog of thousands of titles, Netflix cannot cache everything everywhere. An OCA in India does not need Korean dramas that nobody in that region watches. An OCA in Brazil does not need Bollywood content.

Netflix's caching algorithm uses **popularity predictions** based on:

1. Regional viewing history (what did this ISP's users watch last week?)
2. Trending signals (is a new season of a hit show dropping globally?)
3. Content freshness (new releases get priority cache placement)
4. Time of day patterns (kids content fills OCAs during afternoon hours)

Every night during the fill window, the system evaluates what should be cached where, and pushes delta updates to each OCA. Popular content is replicated broadly. Niche content may only live on a few servers at internet exchange points.

### What Happens When Things Go Wrong

Netflix is famous for chaos engineering. They built the **Simian Army** (Chaos Monkey, Chaos Kong, Latency Monkey) to intentionally break things in production. Their CDN is no exception.

If an OCA fails:

1. The client automatically falls back to the next closest OCA in the ranked list
2. If all OCAs in an ISP are down, traffic routes to OCAs at the nearest Internet Exchange Point (IXP)
3. If regional OCAs are all down, traffic falls back to AWS origin servers (this almost never happens)

The client side logic handles this transparently. The user never sees an error. They might experience a brief quality dip as the stream rebuffers from a more distant server, but playback continues.

### Encoding: One Movie, Hundreds of Files

Before any video reaches an OCA, it goes through Netflix's encoding pipeline. A single movie gets encoded into **hundreds of different versions**: different resolutions (240p to 4K), different bitrates, different codecs (H.264, VP9, AV1), and different audio formats.

Netflix pioneered **per title encoding** where each title gets a custom encoding profile. An animated movie compresses differently than a dark thriller. This means a nature documentary might look great at 3 Mbps while an action movie needs 8 Mbps for the same perceived quality.

The result: Netflix delivers the best possible quality at the lowest possible bandwidth for every single title, on every single device.

### Key Engineering Takeaways

1. **Put the data where the users are, not where your servers are.** Netflix's biggest insight was that cloud computing is great for business logic but terrible for bulk data delivery. By placing servers inside ISP networks, they eliminated the most expensive and slowest part of the path. If your system serves large files or media, consider edge caching seriously.
2. **Separate control plane from data plane.** The Playback Service (control) runs on AWS. The video delivery (data) runs on OCAs. This separation lets each plane scale, fail, and evolve independently. This pattern applies to almost every large scale system: API gateways (control) vs backend services (data), DNS (control) vs CDN (data).
3. **Free hardware is a valid business strategy.** Netflix giving away servers sounds crazy until you calculate the alternative: paying transit costs for 15% of all internet traffic crossing continental backbones. The math works because the cost of a server is tiny compared to years of bandwidth savings. Sometimes the cheapest solution is giving something away.

❝

**Job Opening**

- Software Dev Engineer II, India CFX Team @Amazon: [Apply Here](https://www.amazon.jobs/en/jobs/10422146/software-dev-engineer-ii-amazon-india-cfx-team?utm_campaign=how-netflix-delivers-video-to-300-million-users-without-buffering&utm_medium=referral&utm_source=grindengineer.com)
- Software Development Engineer 2, IN Ads @Amazon: [Apply Here](https://www.amazon.jobs/en/jobs/3205082/software-development-engineer-2-in-ads?utm_campaign=how-netflix-delivers-video-to-300-million-users-without-buffering&utm_medium=referral&utm_source=grindengineer.com)
- Software Engineer, University Graduate 2026 @Google: [Apply Here](https://www.google.com/about/careers/applications/jobs/results/130965312295051974-software-engineer-university-graduate-2026?utm_campaign=how-netflix-delivers-video-to-300-million-users-without-buffering&utm_medium=referral&utm_source=grindengineer.com)
- Software Engineer, PhD Early Career 2026 @Google: [Apply Here](https://www.google.com/about/careers/applications/jobs/results/108281679147082438-software-engineer-phd-early-career-2026?utm_campaign=how-netflix-delivers-video-to-300-million-users-without-buffering&utm_medium=referral&utm_source=grindengineer.com)
- Software Developer Engineer, SmartBiz @Amazon: [Apply Here](https://www.amazon.jobs/en/jobs/10372167/software-developer-engineer?utm_campaign=how-netflix-delivers-video-to-300-million-users-without-buffering&utm_medium=referral&utm_source=grindengineer.com)

Enjoyed the breakdown?

For more visual explanations of system design, DSA patterns, AI in engineering and tech productivity, Subscribe To Grind Engineer! 🚀

Until next time!  
**Scortier**, Signing Off!