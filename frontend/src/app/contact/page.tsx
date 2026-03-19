import type { Metadata } from 'next';
import Header from '@/ui/Header';
import { HEADER_STYLE_PRESETS } from '@/ui/headerStyles';

export const metadata: Metadata = {
  title: 'Contact',
};

export default function Page() {
  return (
    <>
      <Header styles={HEADER_STYLE_PRESETS.solid} />
      <main className="min-h-screen bg-background flex flex-col items-center justify-center px-6 text-center">
        <span className="text-xs tracking-[0.3em] text-foreground/50 uppercase">Contact</span>
        <h1 className="mt-4 text-3xl md:text-4xl font-semibold text-foreground">Work in Progress</h1>
        <p className="mt-6 max-w-md text-base md:text-lg text-foreground/60">お問い合わせページは現在作成中です。</p>
      </main>
    </>
  );
}
