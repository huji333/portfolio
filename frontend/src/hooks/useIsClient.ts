import { useSyncExternalStore } from 'react';

const emptySubscribe = () => () => {};

export function useIsClient(): boolean {
  return useSyncExternalStore(emptySubscribe, () => true, () => false);
}
