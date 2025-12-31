export function getApiBaseUrl(): string {
  const rawUrl = process.env.API_BASE_URL || process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:3000/api';
  return rawUrl.endsWith('/') ? rawUrl.slice(0, -1) : rawUrl;
}
