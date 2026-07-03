import { describe, it, expect, beforeEach, vi } from 'vitest';
import { getSiteUrl } from './site';

describe('getSiteUrl', () => {
  beforeEach(() => {
    vi.unstubAllEnvs();
  });

  it('falls back to the production URL when unset', () => {
    vi.stubEnv('NEXT_PUBLIC_SITE_URL', '');
    expect(getSiteUrl()).toBe('https://kakemu.work');
  });

  it('uses NEXT_PUBLIC_SITE_URL when set', () => {
    vi.stubEnv('NEXT_PUBLIC_SITE_URL', 'https://example.com');
    expect(getSiteUrl()).toBe('https://example.com');
  });

  it('strips a trailing slash', () => {
    vi.stubEnv('NEXT_PUBLIC_SITE_URL', 'https://example.com/');
    expect(getSiteUrl()).toBe('https://example.com');
  });
});
