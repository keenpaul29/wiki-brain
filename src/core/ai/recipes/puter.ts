import type { Recipe } from '../types.ts';

/**
 * Puter.js / Puter API platform provides AI capabilities (including GPT-4o-mini,
 * Claude, Gemini, etc.) and embeddings using OpenAI-compatible endpoints.
 */
export const puter: Recipe = {
  id: 'puter',
  name: 'Puter',
  tier: 'openai-compat',
  implementation: 'openai-compatible',
  base_url_default: 'https://api.puter.com/puterai/openai/v1',
  auth_env: {
    required: ['PUTER_API_KEY'],
    setup_url: 'https://puter.com',
  },
  touchpoints: {
    chat: {
      models: ['gpt-4o-mini', 'gpt-4o', 'claude-3-5-sonnet', 'deepseek-chat'],
      supports_tools: true,
      supports_subagent_loop: true,
      supports_prompt_cache: false,
      max_context_tokens: 128000,
      cost_per_1m_input_usd: 0.15,
      cost_per_1m_output_usd: 0.60,
      price_last_verified: '2026-05-27',
    },
  },
  setup_hint: 'Get a Puter API key at https://puter.com, then `export PUTER_API_KEY=...`',
};
