'use client';

import { useState } from 'react';
import Header, { HEADER_STYLE_PRESETS } from '@/ui/Header';

export default function Page() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  return (
    <>
      <Header
        isMenuOpen={isMenuOpen}
        onToggleMenu={() => setIsMenuOpen((prev) => !prev)}
        onCloseMenu={() => setIsMenuOpen(false)}
        styles={HEADER_STYLE_PRESETS.solid}
      />
      <main className="min-h-screen bg-base-light pt-20 md:pt-24 flex flex-col items-center justify-center px-6 text-center">
        <span className="text-xs tracking-[0.3em] text-gray-500 uppercase">Projects</span>
        <h1 className="mt-4 text-3xl md:text-4xl font-semibold text-gray-900">Work in Progress</h1>
        <p className="mt-6 max-w-md text-base md:text-lg text-gray-600">ブログ記事用ページ</p>
      </main>
    </>
  );
}
