---
title: "The Dictionary Problem: Fast Lookups in Large Collections"
source: "https://substack.com/@francofernando/p-193795555"
author:
  - "[[Franco Fernando]]"
published: 2026-04-11
created: 2026-05-08
description: "From arrays to hash tables and BSTs: the trade-offs behind a classic problem."
tags:
  - "clippings"
---
Hi Friends,

Welcome to the 168th issue of the Polymathic Engineer newsletter.

Let’s say you are building a spell checker that runs directly in the browser. You have a dictionary of over 100,000 words, and every time the user types something, you need to quickly check if the word exists in your dictionary. If it doesn’t, you underline it in red.

The feature sounds easy, but there is a problem: how can you store and search through more than 100,000 words quickly? It would be too slow to send a request to the server for every single word. You need to maintain the dictionary locally and search through it fast, without consuming too much memory.

This is a classic problem in computer science, since it comes up all the time: checking if a username is already taken or if an email is in a contacts list, or verifying whether a URL exists in a cache are all good examples. The main point is always the same: what is the most efficient way to check if something is in a large collection of items?

In this article, we will explore several data structures that solve this problem, starting from the simplest approach and working our way up to more sophisticated solutions. Along the way, we will see how each one makes different trade-offs in terms of speed, memory, and flexibility. This is the outline:

- Abstract data types
- Unsorted arrays
- Sorted arrays and binary search
- Hash tables
- Binary search trees
- Comparing the options

---

#### Your AI shouldn't grade its own homework

![](https://substackcdn.com/image/fetch/$s_!oBf2!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F66478278-656b-4112-a0f1-49bb03ea0435_1558x936.png)

Claude Code writes beautiful code. So does Codex. But here’s the thing, they also think they write beautiful code. And when you ask an AI to review code it just wrote, you get the intellectual equivalent of a student grading their own exam. Shockingly, they always pass.

[CodeRabbit CLI](https://coderabbit.link/fernando) plugs into Claude Code and Codex as an external reviewer, different AI Agent, different architecture, 40+ static analyzers and zero emotional attachment to the code it’s looking at. The agent writes, CodeRabbit reviews, and the agent fixes. Loop until clean.

You show up when there’s actually something worth approving.

One command. Autonomous generate-review-iterate cycles. The AI still does the work. It just doesn’t get to decide if the work is good anymore.

[Free tier available. Try CodeRabbit's CLI.](https://coderabbit.link/fernando)

Thanks to the CodeRabbit team for collaborating with me on this newsletter issue.

---

## Abstract data types

Before jumping into specific solutions for the dictionary problem, it is worth taking a step back and talking about abstract data types.

An abstract data type (ADT) defines what operations a data structure should support, without saying anything about how those operations are really done. It is a contract: you know what you can do with it, but the internal details are hidden.

The reason why it’s important to distinguish between abstract data types and concrete data structures is that it forces you to figure out what you need before thinking about how to make it work.

The ADT we care about here is the dictionary, which is also known as a symbol table, associative array, or map. The ADT dictionary keeps a collection of (key, value) pairs and supports three operations:

- **insert(key, value)**: adds a new pair to the collection
- **remove(key)**: removes the pair associated with the given key
- **contains(key)**: checks if a key exists and returns the associated value

![](https://substackcdn.com/image/fetch/$s_!KPNP!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F5acbb453-0187-4ab2-95a0-d14370cc1a34_814x412.png)

The most crucial thing is that there is only one copy of each key in the collection, and you may get any value directly by using its key. The easiest way to think about this is to consider a regular array as a special case.

In an array like \[”the”, ”lazy”, ”fox”\], the keys are simply the indices 0, 1, and 2, and you can always get a value by providing its position. A dictionary takes this idea further by letting you use keys from almost any domain, such as strings, numbers, or objects.

For the above-mentioned spell checker problem, we actually need a simpler version of the dictionary called a set. A set only knows if a key is there or not; it doesn’t store any values with the keys. You can think of it as a dictionary where values are always either true or false.

## Unsorted arrays

The simplest way to solve our spell checker problem is to dump all 100,000 words into an unsorted array. You don't have to do anything special. You simply store the words in the order you get them.

![](https://substackcdn.com/image/fetch/$s_!7QB6!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F76854f3e-b8f7-49c0-a77c-20df58ebc7dc_393x105.png)

It is easy to add a new word since you can just put it at the end of the array. That takes O(1) time on average. If you don't care about keeping things in order, it is also quick to remove a word. You just swap it with the last element and make the array smaller.

However, things fall apart when it comes to search. If someone types "algorithm" and you need to see whether it is in the dictionary, the only option is go through the array word by word, starting at the beginning and proceeding until you find it or reach the end. In the worst case, that is O(n), which means that for 100,000 words, you may have to look at all the 100,000 entries before you can notify the user that the word is spelled correctly.

Now imagine doing this for every single word the user types. A short paragraph of 200 words would mean up to 20 million comparisons in the worst case. That is not going to work for a feature that needs to feel instant.

![](https://substackcdn.com/image/fetch/$s_!PVEr!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fec551de7-ce3e-4e26-903d-084ff4a72a3d_1546x475.png)

The one good thing about the unsorted array is that it is simple. No extra memory, no upfront cost, and insertion is as fast as it gets. But the O(n) lookup makes it useless for anything beyond very small collections. We need a faster way to search.

## Sorted arrays and binary search

What if we sort the array first? We could take advantage of the ordering to find things much faster instead of scanning word by word.

![](https://substackcdn.com/image/fetch/$s_!R9QW!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F71cce44d-1f56-4e50-9958-c8018f9478c7_393x106.png)

You probably already do this without thinking about it. When you look up a word in a paper dictionary, you don’t read every entry in a paper dictionary from the beginning. You open it somewhere in the middle, look at the first word on that page, and choose whether to go ahead or backward. If you are looking for “binary” and you land on the page starting with “method,” you know you can ignore everything after that page and focus on the first half.

This is exactly how binary search works. You start in the middle of the array, compare the target word with the word at that position, and then discard half of the remaining elements based on the result. Then you repeat the process on the surviving half. Each step cuts the search space in two, so it takes at most O(log n) comparisons to find any word. For 100,000 words, that is circa 17 comparisons, which is a huge improvement with respect to the unsorted array.

The problem is that keeping the array sorted comes at a cost. It takes O(nlogn) time to sort it in the first place, which is acceptable if you only do it once. But you have to find the correct place for the new word and move everything that comes after it every time you want to add a new word. That is O(n) for each insertion. Removing a word has the same issue because you need to shift elements to fill the gap.

![](https://substackcdn.com/image/fetch/$s_!GhY-!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F0e10cb5e-ba4a-4652-9aa5-c41046ecc0b5_1528x490.png)

If the dictionary doesn't change, a sorted array could be a reasonable solution for the spell checker example. But if the dictionary changes a lot, the O(n) cost of adding and removing words will be a problem. We need something that can quickly look up and add things at the same time.

## Hash tables

The idea behind hash tables is simple. What if instead of searching through the array, we could compute exactly where a word should be stored?

![](https://substackcdn.com/image/fetch/$s_!8vEL!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fb3d84928-26f0-4fea-aee0-367809aea271_762x429.png)

A hash table uses a hash function to do this. You give it a word, and it gives you back a number. This number is an index in an array. To insert the word “binary,” you run it through the hash function, get back something like 2,512, and store the word at that position. To check if “binary” is in the dictionary, you run the same function, look at position 4,712, and see if it is there. No scanning, no sorting, or comparing.

This makes both insertion and lookup O(1) on average, which is exactly what we were looking for. However, there is a catch. Since the hash function maps a very large set of possible words to a much smaller array, it is only natural that two different words will sometimes end up in the same position. This is what is called a collision. For example, both "binary" and "garden" might hash to index 2,512.

There are two common ways to handle collisions. With **chaining**, each position in the array has a short list, and you add colliding words to that list. With **open addressing**, you look for the next available slot in the array when a collision happens. Both ways work well as long as the array is large enough compared to the number of elements it holds.

One distinction to keep in mind is the one between hash maps and sets. You can use a hash map to link a value to a key, like putting a word and its meaning together. A hash set only keeps track of whether a key exists or not. We don't require definitions for the spell checkers; we just need to know if the word is there. All we need is a hash set.

![](https://substackcdn.com/image/fetch/$s_!Kl1C!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fe53b3e4b-538b-41a3-840e-f9b2e50839c3_1530x480.png)

With O(1) on average for all the operations that matter, hash tables seem like the clear winner. But they come with a cost: memory. A hash table needs an array that is larger than the number of elements you plan to store, plus extra space to deal with collisions.

## Binary search trees

A binary search tree (BST) takes a different approach. Instead of using a hash function to find where a word goes, it sorts words based on how they compare to each other.

![](https://substackcdn.com/image/fetch/$s_!njTw!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd6b147e2-19ed-4f4f-a090-549b463745b5_452x284.png)

A BST is a tree where each node holds a key, and for every node, all the keys in its left subtree are smaller and all the keys in its right subtree are larger. To add a new word, you start at the root and compare it to the current node. If the word is smaller, you go left. If it is larger, you go right. You keep doing this until you reach an empty spot, and that is where the word goes.

Lookup works similarly. To check if "binary" is in the tree, you start at the root and go down the comparisons. If you get to the word, it is there. If you get to an empty space, it isn't. The number of comparisons is equal to the height of the tree because you get one level deeper each time.

Things start to get interesting here. If the tree is balanced, its height is O(logn), which means that all operations, such as insertion, removal, and lookup, take O(logn) time. It is the same as binary search on sorted arrays, but it doesn't cost O(n) to add or remove items.

![](https://substackcdn.com/image/fetch/$s_!gO6v!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd0fb433e-c5bf-4f43-97db-bae72a7dbae6_1545x467.png)

The main benefit of BSTs over hash tables is ordering. Since the words are organized by comparison, a BST can give you things like finding all words between “apple” and “banana,” or getting the word that comes right before or after a given one. In a hash table, these operations take O(n), whereas in a BST, they take O(log n).

For the spell checker, we don’t need any of that. But if you are building something like an autocomplete feature, where you need to find all words within a range, a BST is the better choice.

## Comparing the options

Now that we have gone through the main data structures, let’s put them side by side and see how they compare.

![](https://substackcdn.com/image/fetch/$s_!Dndm!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd112a473-dd85-4743-aa3d-ba011b5ab23a_1528x626.png)

If all you need is to check whether an element is in a collection and don’t care about the order, hash tables are the clear winner. O(1) on average for lookup, insertion, and removal is hard to beat.

If order is important, BSTs are a better choice. A BST can let you find all the words in a range, get the next or previous element, or get the whole collection in sorted order in O(log n) time. Those operations would take O(n) or more time using a hash table.

Sorted arrays are a solid option when the data doesn’t change. You pay the O(n log n) cost once to sort, and then you get O(log n) lookups with no extra memory. But if you need to add or remove things often, the O(n) cost makes those operations impractical.

Unsorted arrays are only worth considering for very small collections where simplicity and cache speed up outweigh the slow lookup.

For the spell-checker problem, the hash table is the best approach. But something is worth considering: a hash table for 100,000 words still occupies a significant amount of memory.

What if we could trade a small amount of accuracy for a huge reduction in memory? What if we could have a data structure that is as fast as a hash table but uses only a fraction of the space, at the cost of occasionally saying a word is in the dictionary when it is not?

That is exactly what Bloom filters do, and we will explore them in a follow-up article.