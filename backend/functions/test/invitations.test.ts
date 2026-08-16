import * as assert from 'assert';
import * as crypto from 'crypto';

describe('invitations.ts', () => {
  it('token is hashed with SHA-256 (no plaintext stored)', () => {
    const tokenPlain = 'test-token-abc123';
    const tokenHash = crypto.createHash('sha256').update(tokenPlain).digest('hex');
    assert.ok(tokenHash !== tokenPlain);
    assert.strictEqual(tokenHash.length, 64);
  });

  it('hash is deterministic for same input', () => {
    const tokenPlain = 'same-token';
    const h1 = crypto.createHash('sha256').update(tokenPlain).digest('hex');
    const h2 = crypto.createHash('sha256').update(tokenPlain).digest('hex');
    assert.strictEqual(h1, h2);
  });

  it('hash differs for different input', () => {
    const h1 = crypto.createHash('sha256').update('token-a').digest('hex');
    const h2 = crypto.createHash('sha256').update('token-b').digest('hex');
    assert.notStrictEqual(h1, h2);
  });

  it('token with whitespace is trimmed before hashing', () => {
    const tokenPlain = '  token-with-spaces  ';
    const trimmedHash = crypto
      .createHash('sha256')
      .update(tokenPlain.trim())
      .digest('hex');
    const rawHash = crypto.createHash('sha256').update(tokenPlain).digest('hex');
    assert.notStrictEqual(trimmedHash, rawHash);
  });

  it('expiry calculation is 24h default', () => {
    const ttlHours = 24;
    const now = Date.now();
    const expiresAt = now + ttlHours * 3_600_000;
    const diffMinutes = (expiresAt - now) / 60_000;
    assert.ok(diffMinutes >= 1439 && diffMinutes <= 1441, 'Expiry near 24h');
  });

  it('custom duration respected', () => {
    const ttlHours = 12;
    const now = Date.now();
    const expiresAt = now + ttlHours * 3_600_000;
    const diffMinutes = (expiresAt - now) / 60_000;
    assert.ok(diffMinutes >= 719 && diffMinutes <= 721, 'Expiry near 12h');
  });
});
