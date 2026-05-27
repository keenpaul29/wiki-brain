# Configuring OpenAI-Compatible API Providers

GBrain integrates with AI providers via the **Vercel AI SDK**. In addition to native clients for OpenAI, Google Gemini, and Anthropic, GBrain has first-class support for any **OpenAI-compatible** API endpoint (such as Ollama, LM Studio, LiteLLM, DeepSeek, Together AI, or Groq).

Every interaction with LLMs and embedding models routes through GBrain's **AI Gateway** (`src/core/ai/gateway.ts`). This document details how to configure, customize, and verify these OpenAI-compatible configurations.

---

## The Three Touchpoints

GBrain uses models for three primary touchpoints:
1. **Embedding (`embedding_model`)**: Vectorizes documents during import/ingestion and search queries (e.g. `ollama:nomic-embed-text` or `voyage:voyage-3`).
2. **Expansion (`expansion_model`)**: Expands search queries into related phrases for hybrid search (e.g. `groq:llama-3.3-70b-specdec`).
3. **Chat (`chat_model`)**: The engine driving subagents, critics, and interactive chats (e.g. `deepseek:deepseek-chat` or `together:meta-llama/Llama-3.3-70B-Instruct-Turbo`).

---

## Configuration Layers & Precedence

You can set up configuration in three ways. If the same option is configured in multiple places, the precedence order is:

$$\text{Environment Variables (Highest)} > \text{Durable Config File} > \text{Database-Plane Config} > \text{Defaults (Lowest)}$$

### 1. Environment Variables
Best for ephemeral setups, Docker containers, or fast developer workflows.
* **Touchpoints**:
  * `GBRAIN_EMBEDDING_MODEL`: Set the model identifier (e.g. `ollama:nomic-embed-text`).
  * `GBRAIN_EMBEDDING_DIMENSIONS`: The dimension size of your embedding vectors (e.g. `768` or `1536`). *Must match your database schema.*
  * `GBRAIN_EXPANSION_MODEL`: Shorthand/model string for query expansion (e.g. `groq:llama-3.3-70b-specdec`).
  * `GBRAIN_CHAT_MODEL`: Primary chat model (e.g. `deepseek:deepseek-chat`).
* **API Keys**:
  * Set `<PROVIDER>_API_KEY` corresponding to your provider (e.g. `DEEPSEEK_API_KEY`, `GROQ_API_KEY`, `TOGETHER_API_KEY`).
  * Local providers like Ollama running unauthenticated do not require keys.

### 2. Durable Configuration File (`~/.gbrain/config.json`)
The primary place where local machine config is persisted. You can edit this file directly or use the CLI commands:
```powershell
# Show current config
gbrain config show

# Get a specific key
gbrain config get embedding_model

# Set a config value
gbrain config set embedding_model ollama:nomic-embed-text
```

To configure custom endpoints (Base URLs) in `config.json`, add your overrides to the `provider_base_urls` record:
```json
{
  "engine": "pglite",
  "embedding_model": "ollama:nomic-embed-text",
  "embedding_dimensions": 768,
  "chat_model": "deepseek:deepseek-chat",
  "provider_base_urls": {
    "ollama": "http://127.0.0.1:11434/v1",
    "litellm": "http://localhost:4000",
    "deepseek": "https://api.deepseek.com/v1"
  }
}
```

---

## Provider Recipes & Default Base URLs

GBrain includes pre-defined recipes for common OpenAI-compatible API hosts:

| Recipe ID | Provider Name | Default Base URL | Auth / Key Environment Variable |
| :--- | :--- | :--- | :--- |
| `ollama` | Ollama (local) | `http://localhost:11434/v1` | None required (auth optional) |
| `litellm` | LiteLLM Proxy | `http://localhost:4000` | Optional `LITELLM_API_KEY` |
| `deepseek` | DeepSeek | `https://api.deepseek.com/v1` | `DEEPSEEK_API_KEY` |
| `groq` | Groq | `https://api.groq.com/openai/v1` | `GROQ_API_KEY` |
| `together` | Together AI | `https://api.together.xyz/v1` | `TOGETHER_API_KEY` |
| `voyage` | Voyage AI | `https://api.voyageai.com/v1` | `VOYAGE_API_KEY` |

> [!NOTE]
> If you override the API endpoint via the `provider_base_urls` config parameter, the base URL must point to the root `/v1` endpoint (or equivalent containing `/chat/completions` or `/embeddings`).

---

## Step-by-Step Setup Guide

### Option A: Local Embedding + Remote Chat (Zero-Cost Setup)
This is the recommended offline-friendly/hybrid setup: Ollama handles embeddings locally, and a cheap API (like DeepSeek or Groq) handles expansion/chat.

1. **Start Ollama** and pull the embedding model:
   ```bash
   ollama pull nomic-embed-text
   ollama serve
   ```
2. **Initialize your brain** with local PGLite, telling it to use Ollama for embeddings:
   ```bash
   gbrain init --pglite --embedding-model ollama:nomic-embed-text --embedding-dimensions 768
   ```
3. **Configure your API keys and models** via environment variables or direct config set:
   ```bash
   # Export keys in your shell profile
   export DEEPSEEK_API_KEY="sk-..."
   export GBRAIN_CHAT_MODEL="deepseek:deepseek-chat"
   ```

### Option B: Universal LiteLLM Proxy Setup
If you run LiteLLM to proxy Vertex AI, Bedrock, Azure, or private enterprise endpoints, use the `litellm` recipe.

1. **Set the base URL and API key**:
   ```bash
   export LITELLM_BASE_URL="https://your-litellm-gateway.internal"
   export LITELLM_API_KEY="your-token"
   ```
2. **Initialize GBrain** specifying the proxy model:
   ```bash
   gbrain init --pglite --embedding-model litellm:text-embedding-ada-002 --embedding-dimensions 1536
   ```

---

## Verifying & Testing Setup

GBrain provides the `gbrain providers` command suite to list, inspect, and smoke-test your integrations.

### 1. List Providers
Check which providers are defined and whether their authentication requirements are satisfied:
```bash
gbrain providers list
```
*Outputs a table showing the ready status (`✓ ready` or `✗ missing <KEY>`).*

### 2. View Required Environment Variables
To see setup hints, setup URLs, and the list of env vars needed for a specific provider:
```bash
gbrain providers env deepseek
```

### 3. Smoke Test an Endpoint
Verify that GBrain can successfully communicate with the configured model:
```bash
# Test the embedding endpoint
gbrain providers test --touchpoint embedding --model ollama:nomic-embed-text

# Test the chat endpoint
gbrain providers test --touchpoint chat --model deepseek:deepseek-chat
```
*Asserts latency, dimension sizes, token usage, and normalizes any config/network errors.*

### 4. Interactive Matrix Explain
Print a choice matrix detailing cost, dimensions, pros, cons, and auto-detecting locally reachable daemons (such as Ollama or LM Studio):
```bash
gbrain providers explain
```
