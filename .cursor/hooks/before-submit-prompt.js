#!/usr/bin/env node
const { readStdin } = require('./adapter');
readStdin().then(raw => {
  try {
    const input = JSON.parse(raw);
    const prompt = input.prompt || input.content || input.message || '';
    const secretPatterns = [
      { re: /sk-[a-zA-Z0-9]{20,}/, label: 'OpenAI API key' },
      { re: /ghp_[a-zA-Z0-9]{36,}/, label: 'GitHub token' },
      { re: /AKIA[A-Z0-9]{16}/, label: 'AWS access key' },
      { re: /xox[bpsa]-[a-zA-Z0-9-]+/, label: 'Slack token' },
      { re: /-----BEGIN (RSA |EC )?PRIVATE KEY-----/, label: 'Private key' },
      // Crypto-specific patterns
      { re: /[0-9a-fA-F]{64}/, label: 'Possible raw private key (64-char hex)' },
      { re: /[13][a-km-zA-HJ-NP-Z1-9]{25,34}/, label: 'Possible BTC address with value' },
      { re: /0x[a-fA-F0-9]{40}/, label: 'Ethereum address' },
      { re: /T[A-Za-z1-9]{33}/, label: 'Possible TRON address' },
      { re: /seed[\s_-]?phrase/i, label: 'Seed phrase reference' },
      { re: /mnemonic/i, label: 'Mnemonic reference' },
      // Wallet / exchange API keys
      { re: /[a-zA-Z0-9]{32,}-[a-zA-Z0-9]{4,}/, label: 'Possible exchange API key' },
      { re: /eyJ[a-zA-Z0-9_-]{50,}\.eyJ[a-zA-Z0-9_-]{20,}/, label: 'JWT token' },
    ];
    const found = [];
    for (const { re, label } of secretPatterns) {
      if (re.test(prompt)) found.push(label);
    }
    if (found.length > 0) {
      console.error('[VIBE-CODE] ⚠ Potential secret/sensitive data detected in prompt:');
      found.forEach(l => console.error(`  - ${l}`));
      console.error('[VIBE-CODE] Remove before submitting. Use environment variables or placeholders.');
    }
  } catch {}
  process.stdout.write(raw);
}).catch(() => process.exit(0));
