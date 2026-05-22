/**
 * Wiki phase (v1.0) — raw-to-wiki ingestion pipeline.
 *
 * Scans the `raw/` directory for new or changed files using a manifest
 * stored in `wiki/_state/raw-manifest.json`. For each change, it dispatches
 * a Sonnet subagent to:
 *   1. Summarize the raw source into `wiki/sources/`.
 *   2. Identify related concepts and update/create them in `wiki/concepts/`.
 *   3. Update synthesis pages in `wiki/synthesis/` if relevant.
 *   4. Cross-link and add backlinks.
 *
 * After all subagents finish, the orchestrator:
 *   1. Updates `wiki/index.md` (content catalog).
 *   2. Updates `wiki/log.md` (chronological log).
 *   3. Commits the new state to the manifest.
 */

import {
  readFileSync,
  writeFileSync,
  existsSync,
  mkdirSync,
  readdirSync,
  statSync,
} from "node:fs";
import { join, relative, basename } from "node:path";
import { createHash } from "node:crypto";
import type { BrainEngine } from "../engine.ts";
import type { PhaseResult, PhaseError } from "../cycle.ts";
import { MinionQueue } from "../minions/queue.ts";
import {
  waitForCompletion,
  TimeoutError,
} from "../minions/wait-for-completion.ts";
import type { MinionJobInput, SubagentHandlerData } from "../minions/types.ts";

interface WikiConfig {
  enabled: boolean;
  model: string;
}

interface RawFileSnapshot {
  path: string;
  sha256: string;
  length: number;
  last_write_time: string;
}

interface WikiChanges {
  new: RawFileSnapshot[];
  changed: RawFileSnapshot[];
  deleted: string[];
  currentMap: Map<string, RawFileSnapshot>;
}

export interface WikiPhaseOpts {
  brainDir: string;
  dryRun: boolean;
  yieldDuringPhase?: () => Promise<void>;
}

export async function runPhaseWiki(
  engine: BrainEngine,
  opts: WikiPhaseOpts,
): Promise<PhaseResult> {
  const start = Date.now();
  try {
    const config = await loadWikiConfig(engine);
    if (!config.enabled && !opts.dryRun) {
      return skipped("not_configured", "dream.wiki.enabled is false");
    }

    const rawDir = join(opts.brainDir, "raw");
    const wikiDir = join(opts.brainDir, "wiki");
    const stateDir = join(wikiDir, "_state");
    const manifestPath = join(stateDir, "raw-manifest.json");

    if (!existsSync(rawDir)) {
      return ok("raw/ directory not found, skipping wiki ingestion", {
        sources_ingested: 0,
        pages_written: 0,
      });
    }

    // 1. Discovery
    const changes = discoverWikiChanges(opts.brainDir, rawDir, manifestPath);
    const toProcess = [...changes.new, ...changes.changed];

    if (toProcess.length === 0 && changes.deleted.length === 0) {
      return ok("no changes in raw/ directory", {
        sources_ingested: 0,
        pages_written: 0,
      });
    }

    if (opts.dryRun) {
      return ok(
        `dry-run: ${toProcess.length} file(s) would be ingested, ${changes.deleted.length} would be handled as deleted`,
        {
          sources_ingested: 0,
          pages_written: 0,
          new_files: changes.new.map((f) => f.path),
          changed_files: changes.changed.map((f) => f.path),
          deleted_files: changes.deleted,
          dryRun: true,
        },
      );
    }

    // 2. Fan-out
    const allowedSlugPrefixes = await loadAllowedSlugPrefixes();
    const queue = new MinionQueue(engine);
    const childIds: number[] = [];

    for (const file of toProcess) {
      const content = readFileSync(join(opts.brainDir, file.path), "utf8");
      const childData: SubagentHandlerData = {
        prompt: buildWikiIngestPrompt(file.path, content),
        model: config.model,
        max_turns: 30,
        allowed_slug_prefixes: allowedSlugPrefixes,
      };
      const submitOpts: Partial<MinionJobInput> = {
        max_stalled: 3,
        on_child_fail: "continue",
        idempotency_key: `wiki:ingest:${file.path}:${file.sha256.slice(0, 16)}`,
        timeout_ms: 30 * 60 * 1000,
      };
      const child = await queue.add(
        "subagent",
        childData as unknown as Record<string, unknown>,
        submitOpts,
        { allowProtectedSubmit: true },
      );
      childIds.push(child.id);
    }

    // 3. Wait for children
    const childOutcomes: Array<{ jobId: number; status: string }> = [];
    for (const jobId of childIds) {
      try {
        const job = await waitForCompletion(queue, jobId, {
          timeoutMs: 35 * 60 * 1000,
          pollMs: 5 * 1000,
        });
        childOutcomes.push({ jobId, status: job.status });
      } catch (e) {
        childOutcomes.push({
          jobId,
          status: e instanceof TimeoutError ? "timeout" : "error",
        });
      }
      if (opts.yieldDuringPhase) {
        try {
          await opts.yieldDuringPhase();
        } catch {
          /* skip */
        }
      }
    }

    // 4. Update Index and Log
    // We use a final subagent to perform the bookkeeping to ensure consistent formatting
    // and context-aware updates to index.md and log.md.
    const writtenSlugs = await collectChildPutPageSlugs(engine, childIds);
    if (writtenSlugs.length > 0 || changes.deleted.length > 0) {
      const bookkeepingData: SubagentHandlerData = {
        prompt: buildBookkeepingPrompt(
          toProcess,
          changes.deleted,
          writtenSlugs,
        ),
        model: config.model,
        max_turns: 10,
        allowed_slug_prefixes: allowedSlugPrefixes,
      };
      const bookId = await queue.add(
        "subagent",
        bookkeepingData as unknown as Record<string, unknown>,
        {
          idempotency_key: `wiki:bookkeeping:${Date.now().toString().slice(0, 10)}`,
        },
        { allowProtectedSubmit: true },
      );
      await waitForCompletion(queue, bookId.id, { timeoutMs: 10 * 60 * 1000 });
    }

    // 5. Commit state
    mkdirSync(stateDir, { recursive: true });
    writeFileSync(
      manifestPath,
      JSON.stringify(Array.from(changes.currentMap.values()), null, 2),
      "utf8",
    );

    const ms = Date.now() - start;
    return ok(
      `${toProcess.length} source(s) ingested in ${(ms / 1000).toFixed(1)}s`,
      {
        sources_ingested: toProcess.length,
        pages_written: writtenSlugs.length,
        new_files: changes.new.map((f) => f.path),
        changed_files: changes.changed.map((f) => f.path),
        deleted_files: changes.deleted,
        child_outcomes: childOutcomes,
      },
    );
  } catch (e) {
    return failed(
      makeError(
        "InternalError",
        "WIKI_PHASE_FAIL",
        e instanceof Error ? e.message : String(e),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────

async function loadWikiConfig(engine: BrainEngine): Promise<WikiConfig> {
  const enabled = (await engine.getConfig("dream.wiki.enabled")) === "true";
  const { resolveModel } = await import("../model-config.ts");
  const model = await resolveModel(engine, {
    configKey: "models.dream.wiki",
    fallback: "sonnet",
  });
  return { enabled, model };
}

function discoverWikiChanges(
  root: string,
  rawDir: string,
  manifestPath: string,
): WikiChanges {
  const current: RawFileSnapshot[] = [];
  function walk(d: string) {
    for (const entry of readdirSync(d)) {
      if (entry.startsWith(".")) continue;
      const full = join(d, entry);
      const st = statSync(full);
      if (st.isDirectory()) {
        walk(full);
      } else {
        const content = readFileSync(full);
        current.push({
          path: relative(root, full).replace(/\\/g, "/"),
          sha256: createHash("sha256").update(content).digest("hex"),
          length: st.size,
          last_write_time: st.mtime.toISOString(),
        });
      }
    }
  }
  walk(rawDir);

  const previousMap = new Map<string, RawFileSnapshot>();
  if (existsSync(manifestPath)) {
    try {
      const items = JSON.parse(
        readFileSync(manifestPath, "utf8"),
      ) as RawFileSnapshot[];
      for (const item of items) previousMap.set(item.path, item);
    } catch {
      /* ignore bad manifest */
    }
  }

  const currentMap = new Map<string, RawFileSnapshot>();
  for (const item of current) currentMap.set(item.path, item);

  const newList = current.filter((f) => !previousMap.has(f.path));
  const changedList = current.filter((f) => {
    const prev = previousMap.get(f.path);
    return prev && prev.sha256 !== f.sha256;
  });
  const deletedList = Array.from(previousMap.keys()).filter(
    (path) => !currentMap.has(path),
  );

  return {
    new: newList,
    changed: changedList,
    deleted: deletedList,
    currentMap,
  };
}

function buildWikiIngestPrompt(path: string, content: string): string {
  return `You are an expert knowledge curator ingesting a new raw source into the user's persistent wiki.

SOURCE PATH: ${path}
CONTENT:
---
${content}
---

TASKS:
1. SOURCE SUMMARY: Create or update a summary page in \`wiki/sources/\`. 
   Slug: \`wiki/sources/\` + slugified filename.
   Include: Executive summary, key arguments/insights, and source metadata (date, path).
   
2. CONCEPTS: Identify 1-3 core concepts, frameworks, or mental models described in this source.
   Search if they already exist in \`wiki/concepts/\`.
   If new: create a new concept page.
   If exists: update the page with fresh insights from this source (REWRITE, don't just append).
   
3. SYNTHESIS: If this source significantly changes the understanding of a major theme, update the relevant page in \`wiki/synthesis/\`.

RULES:
- Use wikilinks compulsively: [[wiki/sources/example|Example]].
- Cite the source: [Source: ${path}].
- Follow filing rules: file by primary subject.
- DO NOT update index.md or log.md yet (the orchestrator handles this).

When done, list the slugs you created or updated.`;
}

function buildBookkeepingPrompt(
  processed: RawFileSnapshot[],
  deleted: string[],
  writtenSlugs: string[],
): string {
  const date = new Date().toISOString().split("T")[0];
  return `You are the librarian of an LLM-maintained wiki. You need to update the catalog and log after a batch of ingests.

DATE: ${date}
INGESTED SOURCES:
${processed.map((f) => `- ${f.path}`).join("\n")}

DELETED SOURCES:
${deleted.map((d) => `- ${d}`).join("\n")}

WRITTEN WIKI PAGES:
${writtenSlugs.map((s) => `- [[${s}]]`).join("\n")}

TASKS:
1. UPDATE WIKI INDEX (\`wiki/index.md\`):
   - Ensure all new pages are navigable under the correct sections (Synthesis, Concepts, Sources).
   - Maintain the alphabetical or logical order.
   
2. APPEND TO WIKI LOG (\`wiki/log.md\`):
   - Add a new section for [${date}].
   - Summarize what was ingested and what new connections were made.
   
When done, confirm the updates.`;
}

async function collectChildPutPageSlugs(
  engine: BrainEngine,
  childIds: number[],
): Promise<string[]> {
  if (childIds.length === 0) return [];
  const rows = await engine.executeRaw<{ slug: string }>(
    `SELECT DISTINCT input->>'slug' AS slug
       FROM subagent_tool_executions
      WHERE job_id = ANY($1::int[])
        AND tool_name = 'brain_put_page'
        AND status = 'complete'`,
    [childIds],
  );
  return rows
    .map((r) => r.slug)
    .filter(Boolean)
    .sort();
}

async function loadAllowedSlugPrefixes(): Promise<string[]> {
  // Search a few known locations relative to the binary / repo.
  const candidates = [
    join(process.cwd(), "skills", "_brain-filing-rules.json"),
  ];
  for (const path of candidates) {
    if (!existsSync(path)) continue;
    try {
      const raw = readFileSync(path, "utf8");
      const parsed = JSON.parse(raw);
      const globs = parsed?.dream_synthesize_paths?.globs;
      if (Array.isArray(globs)) return globs as string[];
    } catch {
      /* skip */
    }
  }
  return ["wiki/*"]; // Fallback
}

function skipped(reason: string, summary: string): PhaseResult {
  return {
    phase: "wiki",
    status: "skipped",
    duration_ms: 0,
    summary,
    details: { reason },
  };
}

function ok(summary: string, details: any): PhaseResult {
  return { phase: "wiki", status: "ok", duration_ms: 0, summary, details };
}

function failed(error: PhaseError): PhaseResult {
  return {
    phase: "wiki",
    status: "fail",
    duration_ms: 0,
    summary: "wiki phase failed",
    details: {},
    error,
  };
}

function makeError(
  className: string,
  code: string,
  message: string,
): PhaseError {
  return { class: className, code, message };
}
