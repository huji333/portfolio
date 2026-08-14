'use client';

import { useEffect, useState } from 'react';
import { usePathname } from 'next/navigation';
import Header from '@/ui/Header';
import { HEADER_STYLE_PRESETS } from '@/ui/headerStyles';

type SiteHeaderMode = 'auto' | 'solid' | 'light';
type HeaderVariant = 'light' | 'solid';

type SiteHeaderProps = {
  mode?: SiteHeaderMode;
};

const HEADER_OFFSET = 80;

export default function SiteHeader({ mode = 'auto' }: SiteHeaderProps) {
  const pathname = usePathname();
  const isHome = pathname === '/';

  const [variant, setVariant] = useState<HeaderVariant>(() => {
    if (mode === 'light') return 'light';
    if (mode === 'solid') return 'solid';
    return isHome ? 'light' : 'solid';
  });

  useEffect(() => {
    if (mode !== 'auto' || !isHome) {
      setVariant(mode === 'light' ? 'light' : 'solid'); // eslint-disable-line react-hooks/set-state-in-effect -- sync variant with props
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

    let rafId: number | null = null;
    const throttledUpdate = () => {
      if (rafId !== null) return;
      rafId = requestAnimationFrame(() => {
        updateVariant();
        rafId = null;
      });
    };

    let resizeRafId: number | null = null;
    const throttledResize = () => {
      if (resizeRafId !== null) return;
      resizeRafId = requestAnimationFrame(() => {
        updateVariant();
        resizeRafId = null;
      });
    };

    window.addEventListener('scroll', throttledUpdate, { passive: true });
    window.addEventListener('resize', throttledResize);

    return () => {
      window.removeEventListener('scroll', throttledUpdate);
      window.removeEventListener('resize', throttledResize);
      if (rafId !== null) cancelAnimationFrame(rafId);
      if (resizeRafId !== null) cancelAnimationFrame(resizeRafId);
    };
  }, [isHome, mode]);

  return (
    <Header
      styles={HEADER_STYLE_PRESETS[variant]}
    />
  );
}
