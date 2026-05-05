---
title: "Improving Site Performance With Webpack Tree Shaking"
source: "https://medium.com/coursera-engineering/improving-site-performance-with-tree-shaking-491b6a7e0708"
author:
  - "[[David Le]]"
published: 2020-01-10
created: 2026-05-05
description: "1.5K"
tags:
  - "clippings"
---
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*eOLNrh1SKrY_fScgjGKnHA.jpeg)

## Introduction to Tree Shaking

At Coursera, we’re constantly modernizing our code base. Whether it’s the programming language or third-party dependencies, our tools do the most for us when we keep them [up to date](https://medium.com/coursera-engineering/webpack-3-to-4-facing-the-known-unknowns-and-unknown-unknowns-cdfeb817faf8), helping improve developer productivity and application performance. In this blog post, we’ll discuss our approach to improving site performance with ES6 modules and tree shaking.

One of the best ways to improve application performance is to get it for free with the right tooling. This method has long-term benefits since it is automated and less likely to regress. One common example is Javascript minification, which can be enabled with a build tool like Webpack. After introducing ES6 (aka ES2015), Webpack introduced [tree shaking](https://webpack.js.org/guides/tree-shaking/), another performance-enhancing feature that removes dead code to reduce application size.

We use Webpack to build all front-end applications. To be able to take advantage of tree shaking, we had to meet the following criteria:

- Use ES6 module syntax (i.e., import and export).
- Ensure Babel does not compile ES6 module syntax to CommonJS. This is achieved by setting modules=false in babel.rc.
- Set *sideEffects=false* of internal libraries to tell Webpack that modules do not have external dependencies. Webpack proceeds to remove unused code since modules do not have adverse side effects (i.e., mutating global scope).
- Set the Webpack build mode to *mode=production*.

## Migrating to ES6

The primary difference between ES6 and CommonJS is that ES6 imports are static. Webpack uses this static property of ES6 to detect and eliminate dead code at build time. The Coursera front-end codebase had a mixture of ES6 and CommonJS modules. This inconsistency was confusing and decreased developer efficiency.

Here’s a common example.

```c
CommonJS
const { merge } = require('lodash');
ES6
import { merge } from 'lodash';
```

With CommonJS, Webpack not only imports the *merge* function from Lodash when bundling modules, but also everything else from the Lodash library. With ES6 and tree shaking enabled, Webpack is able to statically analyze imports and bundle only used code from Lodash. This decreases the amount of Javascript in the final build.

The large codebase made migrating purely by hand unfeasible. Instead, we decided to use a [codemod](https://github.com/5to6/5to6-codemod) — but then figuring out how to apply the codemod proved more difficult than anticipated. In the first approach, we ran the codemod on the entire code base. The output was hard to code review since there were too many changes. We also found bugs in the output. This was not acceptable and we needed a more manageable way of reviewing the changes to ensure code correctness.

In the second attempt, we applied the codemod individually to each one of Coursera’s 80 single-page applications. This simplified code review, but cross-bundle dependencies made it impossible to localize changes to just one application. In general, when a module uses ES6 syntax for exports, its dependencies must also use ES6 imports. Failure to comply with this would result in broken imports.

Finding and updating imports for cross-application dependencies was not straightforward and required us to either make the changes manually or build additional tooling. In addition, application dependencies made rollbacks harder. After some investigation, we devised a two-phased approach. First, migrate imports for all applications to ES6. These changes can be safely deployed to production. Next, migrate all exports to ES6. This method was safe because with tree shaking disabled, Babel transpiled ES6 imports into the CommonJS variant. Babel cannot easily transpile ES6 exports into CommonJS imports. The following diagram demonstrates this relationship.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*lAijj2ClM8U35AsU)

The two-phased approach required twice as many commits, but had the least potential to affect production.

## Edge Cases

A codemod is a great way to migrate a large codebase to a new standard — however it may not support all edge cases. In the following section, we discuss some edge cases encountered along the way.

## Issue 1

ES6 does not support object destructuring. Brackets are used to import named exports.

Before codemod

```c
const { object: { key } } =  require('path');
```

After codemod

```c
import { object: { key } } from ‘path’; // Syntax Error
```

We manually fixed these issues.

```c
import { object } from ‘path’;
const { key } = object;
```

## Issue 2

CommonJS imports work for files that are using named ES6 exports, but break if changed to ES6.

ModuleA uses a named export.

```c
// ModuleA.js
export const constant1 = ‘constant1’;
```

CommonJS import of named export from ModuleA works.

```c
// ModuleB.js
const constants = require(‘./ModuleA’);
const doSomething = constants.constant1;
```

The codemod output is as follows.

```c
import constants from ‘./ModuleA’; // constants = undefined
```

The *import* is undefined because there is no *default*. We manually fixed these issues.

```c
import { constant1 } from ‘./ModuleA’;
```

## Issue 3

CommonJS exports can be imported in two different ways in ES6, but may break when exports are converted to ES6.

The following example shows interoperability between CommonJS exports and ES6 imports.

```c
// ModuleA.js
exports.constant1 = ‘constant1’; // CommonJS export// ModuleB.js
import { constant1 } from ‘./ModuleA’; // constant1 = ‘constant1’// ModuleC.js
import constants from ‘./ModuleA’; // constants = {constant1: ‘constant1’}
```

Imports break when CommonJS exports are migrated to ES6. Module C has a broken import because Module A does not have a default export.

```c
// ModuleA.js
export const constant1 = ‘constant1’; // ES6 export after code mod// ModuleB.js
import { constant1 } from ‘./ModuleA’; // constant1 = ‘constant1’// ModuleC.js
import constants from ‘pathToFileA’; // constants = undefined
```

## Issue 4

For code splitting, we used React Router and bundle loader (i.e, [bundle-loader](https://github.com/webpack-contrib/bundle-loader)).

```c
// ModuleA.js
const frontPage = loadOnRoute(require(‘lazy!./FrontPage’));
```

Note that *loadOnRoute* is an internal convenience helper for interfacing with React Router.

We migrated the implementation to use ES6 [dynamic imports](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import).

```c
// ModuleA.js
const frontPage = loadOnRoute(import(‘./FrontPage’));
```

On closer inspection, the above code loads the *FrontPage* module immediately when *ModuleA* loads. This was not the desired behavior. What we wanted was to load *FrontPage* on demand. The correct way is to use a function and return the dynamic import.

```c
// ModuleA.js
const frontPage = loadOnRoute(() => import(‘./FrontPage’));
```

## Tree Shake Libraries

Most performance gains came from tree shaking internal and third-party libraries. Even after upgrading to libraries that were tree shakable, we found that Webpack’s conservative approach did not remove all unused code. One example is Lodash.

Lodash exists in two variants: Lodash and Lodash-es. Functionally both versions are the same, but Lodash-es uses ES6 exports and imports instead of CommonJS. After building with Lodash-es, we noticed that the whole library was still bundled with the app. One way to fix the issue is to specify the exact module path instead of using the index file.

```c
// Before. The map function is retrieved from index.js
import { map } from ‘lodash’;// After. The map function is imported directly from the map.js
import map from ‘lodash/map’;
```

With or without tree shaking, only the map module was imported instead of all modules listed in Lodash’s index file. With the help of [babel-plugin-lodash](https://www.npmjs.com/package/babel-plugin-lodash), we were able to do this transformation automatically at build time. We applied this technique to React Router and an internal UI library. This approach reduced the footprint of the internal UI library by 88%.

## Rollout Strategy and Results

We rolled out changes related to the migration as soon as we completed them; however, by default tree shaking was disabled. In testing, we found build issues that affected the functionality of some applications. Knowing this, we took a conservative approach and built a white list so that apps can be individually opted into tree shaking one at a time. We worked with teams across the organization to verify and test their apps before rolling out with tree shaking enabled.

While results varied among apps, we found that the product description page (which received the most traffic) saw a 60% reduction in main bundle size, and overall page speed improvements of 40%.

Our work on performance is not complete. We’re still working on some big performance initiatives. Follow us if you want to hear more, or even better, join us. We’re [hiring](https://about.coursera.org/careers).