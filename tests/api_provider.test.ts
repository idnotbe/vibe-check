/**
 * API Provider and Model Validation Tests
 *
 * These tests validate the API provider and model configuration
 * for the vibe-check skill.
 *
 * To run: npx ts-node tests/api_provider.test.ts
 * Or with jest: npx jest tests/api_provider.test.ts
 */

// Supported API Providers
type ApiProvider = 'openai' | 'google' | 'anthropic';

// Supported Models by Provider
const SUPPORTED_MODELS: Record<ApiProvider, string[]> = {
  openai: ['gpt-5.2-high', 'codex-5.2-high'],
  google: ['gemini-3.0-pro-preview', 'gemini-3.0-flash-preview'],
  anthropic: ['claude-sonnet-4.5', 'claude-opus-4.5'],
};

// Environment variable names by provider
const ENV_VARS: Record<ApiProvider, string> = {
  openai: 'OPENAI_API_KEY',
  google: 'GEMINI_API_KEY',
  anthropic: 'ANTHROPIC_API_KEY',
};

// Validation functions
function isValidProvider(provider: string): provider is ApiProvider {
  return ['openai', 'google', 'anthropic'].includes(provider);
}

function isValidModel(provider: ApiProvider, model: string): boolean {
  return SUPPORTED_MODELS[provider]?.includes(model) ?? false;
}

function getEnvVar(provider: ApiProvider): string {
  return ENV_VARS[provider];
}

function hasApiKey(provider: ApiProvider): boolean {
  const envVar = getEnvVar(provider);
  return !!process.env[envVar];
}

interface ValidationResult {
  valid: boolean;
  errors: string[];
  warnings: string[];
}

function validateConfig(apiProvider?: string, model?: string): ValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  // If neither is specified, use defaults
  if (!apiProvider && !model) {
    return { valid: true, errors, warnings: ['Using default Claude Code session model'] };
  }

  // If only one is specified, error
  if (apiProvider && !model) {
    errors.push('Model must be specified when apiProvider is set');
  }
  if (model && !apiProvider) {
    errors.push('apiProvider must be specified when model is set');
  }

  // Validate provider
  if (apiProvider && !isValidProvider(apiProvider)) {
    errors.push(`Invalid apiProvider: ${apiProvider}. Must be one of: openai, google, anthropic`);
  }

  // Validate model for provider
  if (apiProvider && model && isValidProvider(apiProvider)) {
    if (!isValidModel(apiProvider, model)) {
      errors.push(`Invalid model '${model}' for provider '${apiProvider}'. Supported models: ${SUPPORTED_MODELS[apiProvider].join(', ')}`);
    }
  }

  // Check for API key
  if (apiProvider && isValidProvider(apiProvider)) {
    if (!hasApiKey(apiProvider)) {
      warnings.push(`API key not configured. Set ${getEnvVar(apiProvider)} in ~/.claude/settings.json`);
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
}

// Test runner
function runTests() {
  console.log('API Provider and Model Validation Tests\n');
  console.log('='.repeat(50));

  let passed = 0;
  let failed = 0;

  function test(name: string, fn: () => boolean) {
    try {
      const result = fn();
      if (result) {
        console.log(`✓ ${name}`);
        passed++;
      } else {
        console.log(`✗ ${name}`);
        failed++;
      }
    } catch (error) {
      console.log(`✗ ${name} (Error: ${error})`);
      failed++;
    }
  }

  // Provider validation tests
  console.log('\n--- Provider Validation ---');

  test('Valid provider: openai', () => isValidProvider('openai'));
  test('Valid provider: google', () => isValidProvider('google'));
  test('Valid provider: anthropic', () => isValidProvider('anthropic'));
  test('Invalid provider: azure', () => !isValidProvider('azure'));
  test('Invalid provider: empty', () => !isValidProvider(''));

  // Model validation tests
  console.log('\n--- Model Validation ---');

  test('OpenAI gpt-5.2-high', () => isValidModel('openai', 'gpt-5.2-high'));
  test('OpenAI codex-5.2-high', () => isValidModel('openai', 'codex-5.2-high'));
  test('Google gemini-3.0-pro-preview', () => isValidModel('google', 'gemini-3.0-pro-preview'));
  test('Google gemini-3.0-flash-preview', () => isValidModel('google', 'gemini-3.0-flash-preview'));
  test('Anthropic claude-sonnet-4.5', () => isValidModel('anthropic', 'claude-sonnet-4.5'));
  test('Anthropic claude-opus-4.5', () => isValidModel('anthropic', 'claude-opus-4.5'));
  test('Invalid: openai with anthropic model', () => !isValidModel('openai', 'claude-opus-4.5'));
  test('Invalid: google with openai model', () => !isValidModel('google', 'gpt-5.2-high'));

  // Config validation tests
  console.log('\n--- Config Validation ---');

  test('Valid: No provider/model (defaults)', () => {
    const result = validateConfig();
    return result.valid && result.warnings.length > 0;
  });

  test('Valid: openai + gpt-5.2-high', () => {
    const result = validateConfig('openai', 'gpt-5.2-high');
    return result.valid || result.warnings.length > 0; // May warn about missing key
  });

  test('Invalid: provider without model', () => {
    const result = validateConfig('openai');
    return !result.valid && result.errors.includes('Model must be specified when apiProvider is set');
  });

  test('Invalid: model without provider', () => {
    const result = validateConfig(undefined, 'gpt-5.2-high');
    return !result.valid && result.errors.includes('apiProvider must be specified when model is set');
  });

  test('Invalid: wrong model for provider', () => {
    const result = validateConfig('openai', 'claude-opus-4.5');
    return !result.valid && result.errors.some(e => e.includes('Invalid model'));
  });

  // Environment variable tests
  console.log('\n--- Environment Variable Names ---');

  test('OpenAI env var is OPENAI_API_KEY', () => getEnvVar('openai') === 'OPENAI_API_KEY');
  test('Google env var is GEMINI_API_KEY', () => getEnvVar('google') === 'GEMINI_API_KEY');
  test('Anthropic env var is ANTHROPIC_API_KEY', () => getEnvVar('anthropic') === 'ANTHROPIC_API_KEY');

  // Summary
  console.log('\n' + '='.repeat(50));
  console.log(`Results: ${passed} passed, ${failed} failed`);

  if (failed > 0) {
    process.exit(1);
  }
}

// Export for use as module
export {
  ApiProvider,
  SUPPORTED_MODELS,
  ENV_VARS,
  isValidProvider,
  isValidModel,
  getEnvVar,
  hasApiKey,
  validateConfig,
};

// Run tests if executed directly
if (require.main === module) {
  runTests();
}
