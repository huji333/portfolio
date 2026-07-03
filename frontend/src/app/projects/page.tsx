import type { Metadata } from 'next';
import { Suspense } from 'react';
import Loading from '@/ui/Loading';
import SiteHeader from '../_components/SiteHeader';
import ProjectApp from './_components/ProjectApp';

export const metadata: Metadata = {
  title: 'Projects',
  description: '藤井駆陸が手がけた web 開発プロジェクトの一覧。個人開発を中心に、制作物とその背景をまとめています。',
  openGraph: {
    title: 'Projects | Kakemu Fujii',
    description: '藤井駆陸が手がけた web 開発プロジェクトの一覧。個人開発を中心に、制作物とその背景をまとめています。',
  },
};

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
