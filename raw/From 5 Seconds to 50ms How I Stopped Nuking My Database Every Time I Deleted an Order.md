---
title: "From 5 Seconds to 50ms: How I Stopped Nuking My Database Every Time I Deleted an Order"
source: "https://dev.to/akashpattnaik/from-5-seconds-to-50ms-how-i-stopped-nuking-my-database-every-time-i-deleted-an-order-30l0"
author:
  - "[[Akash Pattnaik]]"
published: 2026-06-13
created: 2026-06-14
description: "My Dessert Shop Dashboard Was Choking on Its Own Data — Here's the Architecture That Fixed... Tagged with nextjs, postgres, supabase, performance."
tags:
  - "clippings"
---
## My Dessert Shop Dashboard Was Choking on Its Own Data — Here's the Architecture That Fixed It

*Next.js App Router · Supabase · PostgreSQL performance · Incremental rollup tables*

---

## The Scene: A Dashboard Loading Like It's On Dial-Up

Picture this: your admin dashboard is open. You want to check last week's sales. You click the date range.

Nothing.

Then a spinner. A long, existential spinner.

Five seconds later — *if you're lucky* — the numbers appear. Meanwhile, your database connection pool is gasping for air, your serverless function has basically taken a lunch break, and somewhere a Postgres row lock is just vibing, holding everything hostage.

That was the state of the analytics dashboard I built for a retail franchise kiosk system on **Next.js App Router + Supabase**. High-volume orders, complex JSON-stored item data, coupons, loyalty coins, packaging options — and every time the admin so much as *glanced* at the dashboard, the server started sweating.

Let me walk you through the disaster, the misguided fix I shipped anyway, and the architecture that actually solved it.

---

## The Root Cause: Your Raw Table Is Not a Reporting Table

The first version of the analytics page was beautifully naive. Admin requests "last 30 days of revenue"? Sure — let's just:

1. **Fetch every order** in that date range from the `orders` table
2. **Parse the JSONB column** `selected_items` (nested arrays of items, quantities, toppings) for each row, in-memory, in a Next.js serverless function
3. **Distribute order-level discounts proportionally** across individual line items in real time (flat Rs. 50 off? Cool, now figure out what fraction of that hits each item after excluding toppings and packaging fees)
4. Aggregate everything into totals
5. Pray

The complexity here is genuinely O(N\_orders). Thousands of orders → thousands of JSON parses → proportional discount math → exhausted connection pool → timeout → 😵

```
BEFORE: Every Dashboard Request

Admin requests 30-day report
         │
         ▼
┌─────────────────────────────────┐
│  Next.js Serverless Function    │
│                                 │
│  SELECT * FROM orders           │
│  WHERE created_at > 30 days ago │  ← Full table scan
│                                 │
│  for each order:                │
│    parse JSONB selected_items   │  ← Memory intensive
│    distribute discount          │  ← CPU intensive
│    aggregate metrics            │
└──────────────┬──────────────────┘
               │  2.5s – 5s
               ▼
         Dashboard UI
         (eventually)
```

Under peak traffic, it was worse. Multiple admins → multiple concurrent full-table aggregation jobs → DB connection pool exhausted → cascade of timeouts. The dashboard became a slot machine where the prize was "maybe you get data."

---

## The Nuclear Rebuild: My First (Very Bad) Fix

Here's the part where I should have thought harder but instead shipped a `/api/admin/rebuild-stats` endpoint.

The logic: whenever something changes — an order deleted, a coupon adjusted — just **rebuild all the aggregate stats from scratch**.

The process was essentially:

- Fetch *all* historical paid orders in batches of 1,000
- Recalculate daily stats, hourly stats, product sales, user lifetime metrics — all in-memory
- `TRUNCATE` the aggregate tables
- Re-insert everything from scratch

This worked. For about two weeks, until the order count hit tens of thousands. Then **a single admin deleting one duplicate order** would trigger a multi-minute full rebuild, lock the DB, and make the dashboard completely unresponsive.

I had essentially built a manual `VACUUM` that punished me for routine housekeeping.

```
The Nuclear Rebuild (❌ Don't Do This)

Admin deletes 1 order
         │
         ▼
POST /api/admin/rebuild-stats
         │
         ▼
┌─────────────────────────────────┐
│  Fetch ALL orders in batches    │  ← O(N) reads
│  of 1,000                       │
│                                 │
│  Recalculate EVERYTHING:        │
│  - daily_stats                  │
│  - hourly_orders                │  ← Minutes of work
│  - product_sales                │
│  - user_stats                   │
│                                 │
│  TRUNCATE aggregate tables      │  ← Row locks everywhere
│  Re-insert entire dataset       │
└─────────────────────────────────┘
         │
         ▼
  Dashboard unusable during rebuild
  (scales linearly with order count 🪦)
```

The fix was worse than the disease. Time to actually solve this properly.

---

## The Epiphany: Pre-Aggregate at Write Time, Not Read Time

The insight that changed everything is deceptively simple:

> **The best time to compute aggregates is when the data is created — not when someone asks for it.**

Instead of running expensive aggregations on every dashboard read, maintain a set of **flat rollup tables** that mirror your aggregated state. Every write (order created, order deleted, order modified) updates these rollup tables **incrementally** and **atomically**.

Dashboard reads become trivial index scans on tiny tables. Writes stay O(1) regardless of historical data size.

### The Rollup Schema

Four lightweight tables cover the entire analytics surface:

```
-- Daily-level counters for date-range reports
daily_stats (
  date, total_orders, total_revenue, 
  packaging_count, packed, discount_total
)

-- Hourly breakdown for kitchen load planning
hourly_orders (
  date, hour, order_count, revenue
)

-- Per-product sales performance
product_sales (
  date, product_id, quantity_sold, revenue
)

-- Customer lifetime value tracking
user_stats (
  user_id, total_orders, total_spent, last_visit
)
```

No joins. No JSON parsing. No discount math. Just numbers, already computed, waiting in indexed rows.

---

## The Architecture Shift

```
AFTER: Dashboard Reads (New Architecture)

Admin requests 30-day report
         │
         ▼
┌─────────────────────────────────┐
│  SELECT SUM(total_revenue),     │
│         SUM(total_orders)       │
│  FROM daily_stats               │
│  WHERE date BETWEEN x AND y     │  ← Index scan on N_days rows
│                                 │
│  SELECT product_id,             │
│         SUM(quantity_sold)      │
│  FROM product_sales             │
│  WHERE date BETWEEN x AND y     │
└──────────────┬──────────────────┘
               │  < 100ms
               ▼
         Dashboard UI ✅
```
```
┌─────────────────────────────────────────────────────────────┐
│                    BEFORE vs. AFTER                         │
├─────────────────────┬───────────────────────────────────────┤
│ Metric              │ Before          │ After               │
├─────────────────────┼─────────────────┼─────────────────────┤
│ Dashboard load time │ 2.5s – 5s       │ < 100ms             │
│ Query complexity    │ O(N_orders)     │ O(N_days)           │
│ Order delete cost   │ O(N) full scan  │ O(1) decrement      │
│ DB connection load  │ Pool exhaustion │ Minimal             │
│ Serverless timeouts │ Frequent        │ Eliminated          │
└─────────────────────┴─────────────────┴─────────────────────┘
```

**50× faster dashboard reads. Zero rebuild jobs. Database stability restored.**

---

## The Implementation: Incremental Reversals on Delete

The magic is in how writes interact with the rollups. Let's look at the delete path — the one that previously triggered the nuclear rebuild.

When an admin deletes an order, the endpoint (`app/api/admin/orders/delete/route.ts`) now does something surgical instead of catastrophic:

**Step 1:** Load the order's metadata *before* deleting it to calculate its exact net contributions.

**Step 2:** Atomically decrement every affected rollup row.

**Step 3:** Delete the raw order.

Here's the actual code for reverting daily stats and product sales:

```
// 1. Fetch the daily rollup row for this order's date
const { data: existingDaily } = await supabase
  .from("daily_stats")
  .select("*")
  .eq("date", dateStr)
  .single();

if (existingDaily) {
  const updatedCount = Math.max(0, existingDaily.total_orders - 1);
  const updatedRevenue = Math.max(0, existingDaily.total_revenue - netRevenue);

  if (updatedCount === 0 && updatedRevenue === 0) {
    // Clean up days that now have no data (keeps the table lean)
    await supabase.from("daily_stats").delete().eq("date", dateStr);
  } else {
    await supabase.from("daily_stats").update({
      total_orders: updatedCount,
      total_revenue: updatedRevenue,
      packaging_count: Math.max(
        0,
        existingDaily.packaging_count - (orderToDel.opted_for_packaging ? 1 : 0)
      ),
      packed: Math.max(0, existingDaily.packed - finalPackedCount),
      discount_total: Math.max(0, existingDaily.discount_total - discountAmount),
    }).eq("date", dateStr);
  }
}

// 2. Revert product-level sales — one UPDATE per line item
for (const item of adjustedItems) {
  const itemRevenue = item.itemTotal - (item.itemDiscount || 0);
  const itemPackaging =
    isFallbackPackaging || item.packaged ? item.quantity * 10 : 0;
  const totalItemRevenueWithPackaging = itemRevenue + itemPackaging;

  const { data: existingSale } = await supabase
    .from("product_sales")
    .select("*")
    .eq("date", dateStr)
    .eq("product_id", item.id)
    .single();

  if (existingSale) {
    const updatedQty = Math.max(0, existingSale.quantity_sold - item.quantity);
    const updatedRevenue = Math.max(
      0,
      existingSale.revenue - totalItemRevenueWithPackaging
    );

    if (updatedQty === 0 && updatedRevenue === 0) {
      await supabase.from("product_sales").delete().eq("id", existingSale.id);
    } else {
      await supabase.from("product_sales").update({
        quantity_sold: updatedQty,
        revenue: updatedRevenue,
      }).eq("id", existingSale.id);
    }
  }
}
```

Notice what's *not* happening here: no fetching of thousands of orders, no TRUNCATE, no full recalculation. Just a handful of targeted `UPDATE` statements touching exactly the rows that need to change.

The same pattern applies to every other rollup: hourly stats get a decrement on the specific `(date, hour)` row. Product sales get decremented per line item. User lifetime stats (`total_orders`, `total_spent`) get decremented, with a secondary query to reset `last_visit` to their *next* most recent order if this was their latest transaction. Even the loyalty coin ledger gets a compensatory `admin_adjust` event inserted — no rebuild, just a corrective entry.

Every operation is **O(1) relative to historical data size.** It doesn't matter if you have 100 orders or 100,000 orders. Deleting one still touches the same number of rollup rows.

---

## One Important Caveat: Keep the Raw Table for Granular Queries

The rollup tables handle aggregated analytics efficiently, but they don't replace raw data entirely. **Dynamic scanning on the `orders` table is still permitted** — but only for narrow, highly-indexed single-day views where you need granular data: custom topping breakdowns, cash vs. UPI payment splits, per-transaction audit trails.

The rule of thumb: **aggregate reads go to rollups, granular inspection goes to the raw table with tight date constraints and proper indexes.**

---

## Key Takeaways for Dashboard Builders

**1\. Your `orders` table is a ledger, not a reporting table.**  
Don't run analytics queries on it directly. Maintain separate, pre-aggregated rollup tables optimized purely for reads.

**2\. Materialized views are great — until you need incremental updates.**  
PostgreSQL's `MATERIALIZED VIEW` requires a full refresh (`REFRESH MATERIALIZED VIEW`) which has similar scalability problems to the nuclear rebuild under heavy write load. Custom rollup tables with incremental math give you more surgical control.

**3\. Move complexity to write time, not read time.**  
Admins reading a dashboard vastly outnumber the frequency of order mutations. A slightly more complex write path (a few extra UPDATE statements on delete) pays for itself thousands of times over in fast reads.

**4\. `Math.max(0, ...)` is your guard rail.**  
When doing decremental math on rollup counters, always clamp to zero. Out-of-order event processing or edge cases can produce negative counters, which will corrupt your data silently.

**5\. Clean up empty rollup rows.**  
When a decrement produces a row where every counter is zero, delete it. This keeps your rollup tables lean and your index scans fast.

**6\. The nuclear rebuild is a trap.**  
A full-rebuild endpoint feels like a safe escape hatch. It's actually a time bomb — completely benign at 500 rows, catastrophic at 50,000. Design the incremental path from day one.

---

## The Stack, For Reference

- **Framework:** Next.js 14 App Router (Server Actions + Route Handlers)
- **Database:** PostgreSQL via [Supabase](https://supabase.com/)
- **Rollup updates:** Supabase JS client with targeted `update()` calls inside the relevant API route handlers
- **Pattern:** Event-driven incremental rollups at write time

---

*Building something similar? Hit a different wall with PostgreSQL performance or Supabase at scale? Drop it in the comments — genuinely curious what patterns others are using for dashboard analytics on high-write systems.*[AWS](https://dev.to/aws)Promoted

[![Promotional image](https://media2.dev.to/dynamic/image/width=775%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fi.imgur.com%2FxXlUArJ.jpeg)](https://aws.amazon.com/products/developer-tools/agent-toolkit-for-aws/?utm_source=devto&utm_medium=display&utm_campaign=agenttoolkit&bb=263683)

## Your AI agent makes the same AWS mistakes every time. We made a list.

Over-broad IAM, the wrong service for the job, patterns that aged out years ago. You've watched your agent make the same AWS mistakes again and again, then fixed them yourself.

The Agent Toolkit for AWS ships skills built around those exact failure points, so the answer you get back is one you can ship. One install, in the tool you already use.