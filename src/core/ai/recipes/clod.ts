import type { Recipe } from '../types.ts';

/**
 * Clod API (clod.io) provides AI capabilities (including GPT, Claude, Gemini,
 * etc.) using OpenAI-compatible endpoints.
 */
export const clod: Recipe = {
  id: 'clod',
  name: 'Clod',
  tier: 'openai-compat',
  implementation: 'openai-compatible',
  base_url_default: 'https://api.clod.io/v1',
  auth_env: {
    required: ['CLOD_API_KEY'],
    setup_url: 'https://app.clod.io',
  },
  touchpoints: {
    chat: {
      models: [
        'gpt-4o-mini',
        'gpt-4o',
        'gpt-5-mini',
        'gpt-5-nano',
        'gpt-5',
        'claude-sonnet-4-5',
        'claude-sonnet-4-0',
        'gemini-2.5-flash',
        'gemini-2.5-pro',
        'deepseek-ai/DeepSeek-R1',
        'grok-3',
        'grok-4',
      ],
      supports_tools: true,
      supports_subagent_loop: true,
      supports_prompt_cache: false,
      max_context_tokens: 128000,
      cost_per_1m_input_usd: 0.15,
      cost_per_1m_output_usd: 0.60,
      price_last_verified: '2026-05-27',
    },
  },
  setup_hint: 'Get a Clod API key at https://app.clod.io, then `export CLOD_API_KEY=...`',
};
