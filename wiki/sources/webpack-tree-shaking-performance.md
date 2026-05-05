---
title: Improving Site Performance With Webpack Tree Shaking
type: source
created: 2026-05-05
source: https://medium.com/coursera-engineering/improving-site-performance-with-tree-shaking-491b6a7e0708
tags:
  - source
  - frontend
  - performance
  - webpack
---

# Improving Site Performance With Webpack Tree Shaking

## Summary

This source describes Coursera's migration toward ES6 modules and Webpack tree shaking to reduce JavaScript bundle size. The main lesson is that frontend performance gains can come from build tooling when the codebase is structured so the bundler can safely remove unused code.

## Key Ideas

- Webpack tree shaking depends on static ES6 `import` and `export` syntax, preserving ES modules through Babel, declaring safe `sideEffects` metadata, and building in production mode.
- Large CommonJS-to-ES6 migrations need staged rollout. Coursera first migrated imports, then exports, because changing exports created more interop risk.
- Codemods help with broad mechanical changes, but still need review for edge cases such as destructured requires, named exports without defaults, CommonJS/ES module interop, and lazy loading semantics.
- Dynamic imports must preserve laziness. A route-level import should pass a function such as `() => import(...)` when the goal is on-demand loading.
- Tree shaking alone may not eliminate all unused code from libraries. Direct module imports and build-time transforms such as lodash-specific rewrites can reduce bundle footprint further.
- Coursera rolled tree shaking out behind an application allowlist and verified teams individually before enabling it broadly.

## Results

The article reports a 60% main bundle size reduction for Coursera's high-traffic product description page and roughly 40% page speed improvement. An internal UI library footprint was reduced by 88% after import-path optimization.

## Links

- Connects to [[concepts/frontend-build-performance|Frontend Build Performance]] (module format, tree shaking, bundle size, and rollout strategy)
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] (codemods still require engineering judgment and review)
