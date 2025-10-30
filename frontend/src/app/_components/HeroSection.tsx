'use client';

import { useEffect, useState } from 'react';
import Image from 'next/image';

const DESKTOP_SLIDES = [
  { src: '/index-pc.jpg', label: 'Fieldnotes 01' },
  { src: '/index-pc-2.jpg', label: 'Fieldnotes 02' },
];

const MOBILE_IMAGE = { src: '/index-ph.jpg', label: 'Fieldnotes 01' };

const SLIDE_INTERVAL = 7000;

export default function HeroSection() {
  const [activeIndex, setActiveIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setActiveIndex((prev) => (prev + 1) % DESKTOP_SLIDES.length);
    }, SLIDE_INTERVAL);

    return () => clearInterval(interval);
  }, []);

  return (
    <section
      className="relative isolate flex min-h-screen items-end overflow-hidden text-white snap-start"
      aria-labelledby="hero-heading"
    >
      <div className="absolute inset-0 md:hidden">
        <Image
          src={MOBILE_IMAGE.src}
          alt={MOBILE_IMAGE.label}
          fill
          priority
          sizes="100vw"
          className="object-cover object-center"
        />
      </div>
      {DESKTOP_SLIDES.map((slide, index) => (
        <div
          key={slide.src}
          className={`absolute inset-0 hidden md:block transition-opacity duration-[1600ms] ease-out ${
            index === activeIndex ? 'opacity-100' : 'opacity-0'
          }`}
          aria-hidden={index !== activeIndex}
        >
          <Image
            src={slide.src}
            alt={slide.label}
            fill
            priority={index === 0}
            sizes="100vw"
            className="object-cover"
          />
        </div>
      ))}
    </section>
  );
}
