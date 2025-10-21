"use client";

import { useState, useEffect, useCallback } from "react";
import Image from "next/image";
import Header from "../layout/Header";

type HeroSlideshowProps = {
  headerTone?: "light" | "dark";
};

const HERO_IMAGES = [
  { pc: "/index-pc.jpg", ph: "/index-ph.jpg" },
  { pc: "/index-pc-2.jpg", ph: "/index-ph-2.jpg" },
];

export default function HeroSlideshow({ headerTone = "light" }: HeroSlideshowProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isHeroReady, setHeroReady] = useState(false);
  const [showLoader, setShowLoader] = useState(true);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex((prevIndex) => (prevIndex + 1) % HERO_IMAGES.length);
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (!isHeroReady) {
      return;
    }

    const timeout = setTimeout(() => setShowLoader(false), 600);
    return () => clearTimeout(timeout);
  }, [isHeroReady]);

  const handleHeroLoaded = useCallback(() => {
    setHeroReady(true);
  }, []);

  return (
    <div className="relative min-h-screen overflow-hidden bg-[#faf7f2]">
      <Header isIndexPage heroTone={headerTone} />

      {showLoader && (
        <div
          className={`absolute inset-0 z-20 flex items-center justify-center bg-[#faf7f2]/80 px-6 transition-opacity duration-500 ${
            isHeroReady ? "opacity-0 pointer-events-none" : "opacity-100"
          }`}
        >
          <div className="w-36 max-w-sm md:w-48">
            <div className="h-[3px] w-full overflow-hidden rounded-full bg-black/15">
              <div
                className={`h-full rounded-full bg-black transition-[width] duration-700 ease-out ${
                  isHeroReady ? "w-full" : "w-1/5"
                }`}
              />
            </div>
          </div>
        </div>
      )}

      {HERO_IMAGES.map((image, index) => (
        <div
          key={image.pc}
          className={`absolute inset-0 hidden transition-opacity duration-1000 md:block ${
            index === currentIndex ? "opacity-100" : "opacity-0"
          }`}
        >
          <Image
            src={image.pc}
            alt={`slide-${index}`}
            fill
            className="object-cover"
            priority={index === 0}
            loading={index === 0 ? "eager" : undefined}
            onLoadingComplete={index === 0 ? handleHeroLoaded : undefined}
          />
        </div>
      ))}

      <div className="absolute inset-0 md:hidden">
        <Image
          src={HERO_IMAGES[0].ph}
          alt="slide-fixed"
          fill
          className="object-cover object-bottom"
          priority
          loading="eager"
          onLoadingComplete={handleHeroLoaded}
        />
      </div>
    </div>
  );
}
