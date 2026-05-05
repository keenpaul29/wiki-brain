---
title: Electron Screen Capture Protection
type: source
created: 2026-05-05
source: https://medium.com/gitconnected/how-i-made-a-desktop-app-invisible-to-screen-sharing-electron-os-level-tricks-5734513c1e67
tags:
  - source
  - electron
  - desktop
  - security
---

# Electron Screen Capture Protection

## Summary

This source explains how an Electron overlay can be visible to the local user while excluded from common screen-sharing capture paths. It combines Electron window properties, OS-level capture exclusion, focus management, click-through behavior, global shortcuts, and platform-specific testing.

## Key Ideas

- `BrowserWindow.setContentProtection(true)` maps to `SetWindowDisplayAffinity(... WDA_EXCLUDEFROMCAPTURE)` on Windows and `NSWindowSharingNone` on macOS.
- Transparent, frameless, shadowless, taskbar-hidden windows reduce visible UI artifacts.
- Always-on-top level, full-screen workspace visibility, and panel-like behavior help overlays stay available without ordinary app switching.
- `showInactive()` avoids stealing browser focus, which matters when web apps listen for `blur` or `visibilitychange`.
- Click-through states use `setIgnoreMouseEvents(true, { forward: true })` so the overlay does not block the underlying application.
- Declarative visibility configs reduce bugs from scattered calls to opacity, focus, taskbar, and content-protection APIs.
- macOS screen sharing has app-specific edge cases; Zoom may require advanced capture with window filtering.
- Ongoing testing across OS versions, capture apps, and focus behavior is part of the product, not a one-time step.

## Links

- Connects to [[concepts/reliability-and-operations|Reliability and Operations]] (security-sensitive desktop behavior and test matrices)
- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]] (OS-level platform APIs as deployment constraints)

