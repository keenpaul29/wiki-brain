---
title: "Netflix Open Connect CDN Strategy"
type: source
created: 2026-06-05
source: https://grindengineer.com/p/how-netflix-delivers-video-to-300-million-users-without-buffering
author: "Aditya Singh Sisodiya"
tags:
  - source
  - cdn
  - system-design
  - video-streaming
---

# Netflix Open Connect CDN Strategy

## Summary

Describes Netflix Open Connect as a purpose-built CDN for video delivery. The case study emphasizes edge placement inside ISP networks, predictive off-peak content fill, client-side fallback, control-plane/data-plane separation, and per-title encoding.

## Key Ideas

- Netflix avoids sending most video bytes through the cloud by placing Open Connect Appliances inside or near ISP networks.
- The system splits into two phases: off-peak fill from origin to edge caches, then serve-time delivery from the closest healthy appliance.
- AWS remains the control plane for authentication, playback authorization, manifest generation, and traffic steering.
- The data plane is local video-byte delivery from Open Connect Appliances to user devices.
- Predictive caching decides which titles to pre-position by region, popularity, freshness, and viewing patterns.
- Client fallback handles overloaded or failed appliances by trying alternative OCAs, internet exchange points, or origin paths.
- Per-title encoding creates many bitrate, codec, resolution, and audio variants so each device can stream at the best quality for its bandwidth.
- The business strategy works because giving hardware to ISPs can be cheaper than paying long-term bandwidth and transit costs.

## Links

- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Supports [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
