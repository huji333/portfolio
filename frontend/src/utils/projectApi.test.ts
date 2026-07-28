import { describe, it, expect, vi, beforeEach } from 'vitest';
import { fetchProjects } from './projectApi';

vi.mock('@/utils/api', () => ({
  apiFetch: vi.fn(),
}));

import { apiFetch } from '@/utils/api';
const mockApiFetch = vi.mocked(apiFetch);

const baseProject = {
  id: 1,
  title: 'Project',
  link: 'https://example.com',
  description: null,
  file: null,
};

describe('fetchProjects', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('normalizes missing tags to an empty array', async () => {
    mockApiFetch.mockResolvedValue({ data: [{ ...baseProject }], error: false });

    const result = await fetchProjects();
    expect(result).toEqual({
      projects: [{ ...baseProject, tags: [] }],
      error: false,
    });
  });

  it('keeps tags as-is when present', async () => {
    mockApiFetch.mockResolvedValue({
      data: [{ ...baseProject, tags: ['a', 'b'] }],
      error: false,
    });

    const result = await fetchProjects();
    expect(result).toEqual({
      projects: [{ ...baseProject, tags: ['a', 'b'] }],
      error: false,
    });
  });

  it('returns empty projects on error', async () => {
    mockApiFetch.mockResolvedValue({ data: null, error: true });

    const result = await fetchProjects();
    expect(result).toEqual({ projects: [], error: true });
  });
});
