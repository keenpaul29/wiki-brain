# Self-Growing Brain

A **Self-Growing Brain** is a design pattern where the local wiki, database storage, and daily automation work together so knowledge is not just stored, but also discovered, cross-referenced, and consolidated over time. 

Rather than relying on static folder hierarchies, a self-growing brain dynamically learns from its own inputs, escalating entity importance and rectifying logical contradictions on autopilot.

---

## Architectural Layers

```mermaid
graph TD
    A[Raw Source Material raw/] -->|Step 1: Ingest| B[Local Wiki wiki/]
    B -->|Step 2: Sync| C[(PGLite DB brain source)]
    C -->|Step 3: Dream Cycle| D[Entity Escalation & Link Extraction]
    D -->|Step 4: Consolidate| B
    C -->|Step 5: Contradiction Check| E[Judge Model Alert]
    C -->|Step 6: Embed| F[Recall vector(1536)]
```

### 1. Ingestion Layer: Wiki + Raw Source Material
* **`raw/`**: Holds immutable raw source documents (PDFs, transcripts, markdown articles, media). Agents should never edit these files directly.
* **`wiki/`**: Managed knowledge base organized into `sources/` (summaries), `concepts/` (intellectual map), and `synthesis/` (high-level overviews).
* **`wiki/_state/`**: Holds scan manifests (`raw-manifest.json`) and daily delta reports (`daily-scan.md`).

### 2. Source Database Layer: `brain` Source & Sync
* Local database: `C:\Users\giftlaya\.gbrain\brain.pglite` (scoping files to `--source brain`).
* Running `gbrain sync --source brain --no-pull --no-embed` keeps the local markdown repository and the SQLite/Postgres DB perfectly synchronized.
* The `--no-pull` flag ensures your local changes are committed and processed locally before syncing back to any git remote.

### 3. Automation & Dream Layer
Overnight, the brain runs its **Dream Cycle** (`gbrain dream`) to perform heavy-lifting analysis without disrupting live user sessions:
* **`extract`**: Idempotently extracts links and timeline events without LLM calls.
* **`patterns`**: Identifies entity mentions and auto-generates stub pages for frequently mentioned entities.
* **`consolidate`**: Synthesizes multiple scattered facts into unified `## Facts` tables.
* **`wiki`**: Feeds newly ingested `raw/` files into a Sonnet-driven wiki ingest pipeline.

---

## Powerful Self-Growing Features

### 1. Automated Pull & Adjust Integration (`bun run pull`)
We have automated the upstream pull process. Running `bun run pull` executes [scripts/pull-gbrain.ps1](file:///c:/Users/giftlaya/Documents/my-codes/brain/brain/scripts/pull-gbrain.ps1) which:
1. Performs a `git pull garrytan master` to fetch the latest gbrain engine updates.
2. Automatically resolves code formatting conflicts (like quotes or styling changes) by selecting the upstream versions (`--theirs`) for the core directories (`src/`, `test/`).
3. Keeps your custom wiki rules (`skills/_brain-filing-rules.json`), custom documentation layouts (`scripts/llms-config.ts`), and ignores (`.gitignore`) perfectly preserved.
4. Updates dependencies with `bun install --ignore-scripts` and applies database schema migrations.
5. Performs a clean source sync (`gbrain sync --source brain --no-embed --no-pull`) to keep the DB in lockstep.

### 2. Deterministic vs. Judgment Routing (Minions)
The self-growing brain utilizes a Postgres-native job queue (**Minions**) to optimize cost and performance:
* **Deterministic Tasks** (sync, link extraction, file moves, indexing): Routed directly to local Minions. They run at **$0 token cost** and survive worker/system restarts.
* **Judgment Tasks** (summarization, concept synthesis, contradiction checks): Routed to reasoning models (like Claude 3.5 Sonnet) to write and update the wiki structure.

### 3. Dynamic Schema Evolvement (`gbrain schema`)
Your brain's taxonomy is not static. If you introduce a new type of source material (e.g., medical records, legal briefs, code repos), you can dynamically adjust the database schema:
* Run `gbrain schema detect` to cluster your directory shapes.
* Run `gbrain schema suggest` to generate an LLM proposal for custom type schemas.
* Apply mutations with `gbrain schema use <pack>` to dynamically upgrade structural indexing.

### 4. Suspected Contradictions Solver
During the nightly dream cycle, the brain runs an anomaly detector that pairs related claims:
* Scans all stored facts using date ranges and semantic proximity.
* Submits conflicting statements (e.g. "Acme raised $5M" vs "Acme raised $2M") to a critic model.
* Adds flag markers to the database and logs unresolved conflicts in the dream cycle summary.

---

## Daily CADENCE (The Loop)

1. **Add or Edit Raw Material**: Drop raw text, markdown, or PDFs into `raw/`.
2. **Scan & Generate Manifest**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1
   ```
3. **Ingest Changed Files**:
   ```bash
   bun run dev dream --phase wiki
   ```
   *Creates summaries in `wiki/sources/` and updates concepts/synthesis files.*
4. **Sync to Database**:
   ```bash
   bun run dev sync --source brain --no-embed --no-pull
   ```
5. **Run the Dream Cycle**:
   ```bash
   bun run dev dream
   ```
   *Overnight consolidation, link repair, and contradiction checks.*
6. **Reindex & Refresh Recall**:
   ```bash
   bun run dev embed --stale
   bun run dev doctor
   ```

---

## Architectural Guardrails

* **Do not edit `raw/` files**: They are the golden immutable records of the brain.
* **Always run local commands with `--source brain`**: Prevents files from leaking into the generic `default` source.
* **Review files before pushing**: Run `gbrain doctor` weekly to ensure that your local schema width matches your embedding dimension configuration.
