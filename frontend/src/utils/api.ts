export function getApiBaseUrl(): string {
  const rawUrl = process.env.API_BASE_URL || process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:3000/api';
  return rawUrl.endsWith('/') ? rawUrl.slice(0, -1) : rawUrl;
}

export type ApiRequestInit = RequestInit & {
  next?: { revalidate?: number };
};

function stripServerOnlyOptions(init: ApiRequestInit): RequestInit {
  if (typeof window !== 'undefined') {
    const { next: _, ...rest } = init;
    return rest;
  }
  return init;
}

export async function apiFetch<T>(
  path: string,
  label: string,
  fetchInit?: ApiRequestInit,
): Promise<{ data: T; error: boolean }> {
  const url = `${getApiBaseUrl()}${path}`;
  const init = fetchInit ? stripServerOnlyOptions(fetchInit) : undefined;

  try {
    const response = await fetch(url, init);
    if (!response.ok) {
      console.error(`Failed to fetch ${label}:`, response.statusText);
      return { data: [] as unknown as T, error: true };
    }
    return { data: (await response.json()) as T, error: false };
  } catch (error) {
    console.error(`Failed to fetch ${label}:`, error);
    return { data: [] as unknown as T, error: true };
  }
}
