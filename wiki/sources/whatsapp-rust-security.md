---
title: "Rust at Scale: WhatsApp Security"
type: source
created: 2026-06-04
source: https://engineering.fb.com/2026/01/27/security/rust-at-scale-security-whatsapp/
author: "Daniel Sommermann; Baojun Wang"
tags:
  - source
  - rust
  - security
  - whatsapp
---

# Rust at Scale: WhatsApp Security

## Summary

Meta describes WhatsApp's rollout of a Rust media consistency library to billions of devices as a defense-in-depth layer against malicious or non-conformant media files. The rewrite replaced a large C++ media-checking library with Rust while preserving compatibility through differential fuzzing and integration tests.

## Key Ideas

- The 2015 Stagefright Android vulnerability motivated WhatsApp to protect users even when operating-system media libraries remained unpatched.
- Media parsing is a high-risk attack surface because apps process untrusted files automatically on download.
- WhatsApp rewrote its media consistency library in Rust in parallel with the C++ implementation, then used differential fuzzing and extensive tests to ensure compatible behavior.
- The rollout replaced roughly 160,000 lines of C++ with roughly 90,000 lines of Rust including tests, while improving performance and runtime memory usage.
- The resulting Kaleidoscope checks detect non-conformant structures, risky embedded elements, spoofed file types, MIME/extension mismatches, and known dangerous attachment classes.
- Rust adoption is part of a broader security program: attack-surface reduction, assurance for remaining C/C++ code, static analysis, audits, fuzzing, supply-chain controls, CVE reporting, and strict fix SLAs.

## Links

- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Supports [[concepts/system-design|System Design]]
