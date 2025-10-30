import { Suspense } from 'react';
import Loading from '@/ui/Loading';
import SiteHeader from '../_components/SiteHeader';
import ProjectApp from './_components/ProjectApp';

export default function Page() {
  return (
    <>
      <SiteHeader />
      <Suspense fallback={<Loading className="mx-auto w-full max-w-6xl px-4 py-10" label="Loading projects…" />}>
        <ProjectApp />
      </Suspense>
    </>
  );
}
