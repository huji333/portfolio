'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';

const SLIDES = [
  { pc: '/index-pc.jpg', ph: '/index-ph.jpg', label: 'Fieldnotes 01' },
  { pc: '/index-pc-2.jpg', ph: '/index-ph-2.jpg', label: 'Fieldnotes 02' },
];

const SLIDE_INTERVAL = 7000;

export default function HeroSection() {
  const [activeIndex, setActiveIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setActiveIndex((prev) => (prev + 1) % SLIDES.length);
    }, SLIDE_INTERVAL);

    return () => clearInterval(interval);
  }, []);

  return (
    <section
      className="relative isolate flex min-h-screen items-end overflow-hidden text-white snap-start"
      aria-labelledby="hero-heading"
    >
      {SLIDES.map((slide, index) => (
        <div
          key={slide.pc}
          className={`absolute inset-0 transition-opacity duration-[1600ms] ease-out ${
            index === activeIndex ? 'opacity-100' : 'opacity-0'
          }`}
          aria-hidden={index !== activeIndex}
        >
          <Image
            src={slide.pc}
            alt="portfolio-hero"
            fill
            priority={index === 0}
            sizes="100vw"
            className="hidden object-cover md:block"
          />
          <Image
            src={slide.ph}
            alt="portfolio-hero-mobile"
            fill
            priority={index === 0}
            sizes="100vw"
            className="object-cover object-center md:hidden"
          />
        </div>
      ))}
    </section>
  );
}
