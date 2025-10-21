'use client';

import { ReactNode, useEffect, useRef, useState } from 'react';
import HeroSlideshow from './HeroSlideshow';

type HomePageClientProps = {
  aboutSection: ReactNode;
};

export default function HomePageClient({ aboutSection }: HomePageClientProps) {
  const aboutRef = useRef<HTMLElement | null>(null);
  const [headerTone, setHeaderTone] = useState<'light' | 'dark'>('light');

  useEffect(() => {
    const target = aboutRef.current;
    if (!target || typeof IntersectionObserver === 'undefined') {
      return;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.target === target) {
            setHeaderTone(entry.isIntersecting ? 'dark' : 'light');
          }
        });
      },
      {
        threshold: 0.35,
      },
    );

    observer.observe(target);

    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    const target = aboutRef.current;
    if (!target) {
      return;
    }

    const rect = target.getBoundingClientRect();
    const viewportHeight = window.innerHeight || document.documentElement.clientHeight;
    const isVisible = rect.top < viewportHeight && rect.bottom > 0;
    setHeaderTone(isVisible ? 'dark' : 'light');
  }, []);

  return (
    <div className="h-screen snap-y snap-mandatory overflow-y-auto scroll-smooth">
      <section className="snap-start snap-always">
        <HeroSlideshow headerTone={headerTone} />
      </section>
      <main
        ref={aboutRef}
        className="snap-start snap-always min-h-screen bg-base-light px-6 pb-20 pt-28"
      >
        {aboutSection}
      </main>
    </div>
  );
}
