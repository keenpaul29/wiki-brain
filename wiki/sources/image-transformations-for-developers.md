---
title: "Image Transformations for Developers"
type: source
created: 2026-06-06
source: https://cloudinary.com/documentation/image_transformations
author: "Cloudinary"
tags:
  - source
  - cdn
  - image-processing
  - web-performance
---

# Image Transformations for Developers

## Summary

Cloudinary's reference documentation for dynamic image transformations via URL parameters. Covers URL syntax, chained transformations, automatic format selection, face detection, resizing and cropping modes, effects, layering, and SDK helpers. Images are transformed on the fly and delivered through a global CDN with caching.

## Key Ideas

- Cloudinary URLs follow the structure: `https://res.cloudinary.com/<cloud>/image/upload/<transformations>/<version>/<public_id>.<ext>`.
- Transformation parameters split into action parameters (perform an operation) and qualifier parameters (adjust behavior). Best practice: one action per URL component, chained via slashes.
- Automatic format selection (`f_auto`) delivers WebP or AVIF based on browser support. Quality auto (`q_auto`) balances file size and visual quality.
- Smart cropping modes: face detection (`g_face`), auto gravity (`g_auto`), and thumbnails (`c_thumb`) focus crops on the most relevant image region.
- Chained transformations execute in sequence — each action applies to the result of the previous one. SDKs support array-based transformation chains.
- Derived assets cached on CDN; version component bypasses cache for updated assets. Usage is counted per transformation operation and factors into pricing.

## Links

- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/frontend-build-performance|Frontend Build Performance]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
