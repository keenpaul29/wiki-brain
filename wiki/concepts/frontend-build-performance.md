---
title: Frontend Build Performance
type: concept
created: 2026-05-05
tags:
  - concept
  - frontend
  - performance
  - build-tools
---

# Frontend Build Performance

Frontend build performance work focuses on reducing the JavaScript, CSS, and other assets shipped to users without depending on manual cleanup alone. The Webpack tree-shaking source shows this as an architecture and rollout problem, not only a bundler checkbox.

## Tree Shaking Requirements

- Bundlers need static module structure to eliminate unused code, so ES6 `import` and `export` syntax is easier to optimize than CommonJS `require`.
- Transpilation settings matter. If Babel rewrites ES modules to CommonJS before Webpack analyzes them, tree shaking loses useful static information.
- Package metadata such as `sideEffects: false` tells the bundler that unused modules can be dropped without changing program behavior.
- Production build mode enables the optimization passes needed for dead-code elimination.

## Migration Strategy

- Large module-system migrations should be split into reviewable, deployable phases.
- Imports can often move to ES6 before exports, reducing the blast radius while preserving runtime behavior.
- Codemods should be treated as accelerators, not authority. Edge cases around destructuring, default-versus-named exports, CommonJS interop, and dynamic imports need human review.
- Performance optimizations should roll out incrementally, ideally with application-level opt-in and verification before broad enablement.

## Library Footprint

Tree-shakable libraries still need import discipline. Importing from package indexes can keep too much code reachable; direct module paths or build-time import transforms can produce smaller bundles.

## Broader Frontend Skill Surface

Frontend performance is now part of a broader senior frontend skill set. [[sources/frontend-skills-2026|Frontend Skills Beyond React in 2026]] maps the differentiation areas beyond baseline React fluency:

### TypeScript State Modeling

Beyond basic types, senior work includes discriminated unions for state machines, generic utility types for reusable patterns, conditional types for type-level programming, and exhaustive switch handling to make illegal states unrepresentable. Type safety is a build-time performance tool — catching invalid state transitions before they reach production eliminates an entire class of runtime errors.

### App Router Rendering and Caching Mental Model

Next.js App Router requires understanding the interaction between server components (zero client JS), client components (interactive islands), streaming (Suspense boundaries), and the cache hierarchy (data cache, full route cache, router cache). The key insight: different rendering strategies serve different data freshness and interactivity needs, and choosing the wrong strategy increases both bundle size and time-to-interactive.

### Disciplined Component Extraction

Tailwind utility classes accelerate initial development but can create readability and maintainability debt without extraction discipline. The pattern: build with utilities, then extract repeated combinations into reusable components or composite class abstractions. Map component variants to design tokens rather than ad-hoc values.

## AI UX Patterns

AI features introduce new frontend patterns that interact with performance:

- **Streaming responses**: AI-generated content (chat, summaries, search results) arrives incrementally. The UI must handle partial renders, cancellation, and reconnection without breaking the layout.
- **Optimistic UI with async verification**: user actions appear instant (optimistic update) while the server or AI agent validates the result. If the validation fails, the UI must roll back gracefully.
- **Search / summarization / chat interfaces**: these are fundamentally different interaction models from CRUD forms. They need their own component architecture (conversation history, streaming text, model-selector, context panel) rather than being bolted onto existing patterns.
- **Performance budget interaction**: AI responses have unpredictable latency. The frontend cannot control the model's generation time, so it must manage the user's perception of that latency — loading skeletons, progressive disclosure, and interaction hints.

## Performance Infrastructure Integration

Frontend build performance connects to the broader system design infrastructure:

| Concern | Frontend Tool | Infrastructure Layer |
|---|---|---|
| Asset delivery | CDN cache headers, Brotli compression | [[concepts/infrastructure-primitives|Infrastructure Primitives]] (CDN) |
| Image optimization | srcset, WebP/AVIF, lazy loading | [[concepts/infrastructure-primitives|Infrastructure Primitives]] (CDN, image transformation) |
| API response size | GraphQL field selection, pagination | [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] |
| Cache strategy | Service Worker, SWR, stale-while-revalidate | [[concepts/data-storage-and-consistency|Data Storage and Consistency]] (caching) |
| Error resilience | Error boundaries, fallback UI, retry logic | [[concepts/reliability-and-operations|Reliability and Operations]] (fault tolerance) |

Performance is not a frontend-only concern. The CDN strategy, API design, caching layer, and error handling all determine what load the frontend sees and how fast it can render.

## Links

- Parent: [[concepts/system-design|System Design]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Related: [[concepts/shared-engineering-language|Shared Engineering Language]]
- Source: [[sources/webpack-tree-shaking-performance|Improving Site Performance With Webpack Tree Shaking]]
- Source: [[sources/frontend-skills-2026|Frontend Skills Beyond React in 2026]]
