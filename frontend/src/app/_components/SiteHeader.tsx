'use client';

import { useEffect, useState } from 'react';
import { usePathname } from 'next/navigation';
import Header, { HEADER_STYLE_PRESETS } from '@/ui/Header';

type SiteHeaderMode = 'auto' | 'solid' | 'light';
type HeaderVariant = 'light' | 'solid';

type SiteHeaderProps = {
  mode?: SiteHeaderMode;
};

const HEADER_OFFSET = 80;

export default function SiteHeader({ mode = 'auto' }: SiteHeaderProps) {
  const pathname = usePathname();
  const isHome = pathname === '/';

  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [variant, setVariant] = useState<HeaderVariant>(() => {
    if (mode === 'light') return 'light';
    if (mode === 'solid') return 'solid';
    return isHome ? 'light' : 'solid';
  });

  useEffect(() => {
    setIsMenuOpen(false);
  }, [pathname]);

  useEffect(() => {
    if (mode === 'light') {
      setVariant('light');
      return;
    }

    if (mode === 'solid') {
      setVariant('solid');
      return;
    }

    if (!isHome) {
      setVariant('solid');
      return;
    }

    const updateVariant = () => {
      const aboutSection = document.getElementById('about');
      if (!aboutSection) {
        setVariant('light');
        return;
      }

      const { top } = aboutSection.getBoundingClientRect();
      setVariant(top > HEADER_OFFSET ? 'light' : 'solid');
    };

    updateVariant();

    window.addEventListener('scroll', updateVariant, { passive: true });
    window.addEventListener('resize', updateVariant);

    return () => {
      window.removeEventListener('scroll', updateVariant);
      window.removeEventListener('resize', updateVariant);
    };
  }, [isHome, mode]);

  const toggleMenu = () => setIsMenuOpen((prev) => !prev);
  const closeMenu = () => setIsMenuOpen(false);

  return (
    <Header
      isMenuOpen={isMenuOpen}
      onToggleMenu={toggleMenu}
      onCloseMenu={closeMenu}
      styles={HEADER_STYLE_PRESETS[variant]}
    />
  );
}
