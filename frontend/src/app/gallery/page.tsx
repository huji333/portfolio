'use client';

import { useState } from 'react';
import Header, { HEADER_STYLE_PRESETS } from '@/ui/Header';
import GalleryApp from './_components/GalleryApp';

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
      <div className="min-h-screen bg-[#faf7f2]">
        <GalleryApp />
      </div>
    </>
  );
}
