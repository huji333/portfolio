"use client";

import { useState, useEffect, useCallback } from "react";
import Image from "next/image";
import Header from "./components/layout/Header";

// 画像の配列（PC用とスマホ用）
const images = [
  { pc: "/index-pc.jpg", ph: "/index-ph.jpg" },
  { pc: "/index-pc-2.jpg", ph: "/index-ph-2.jpg" },
];

export default function Home() {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isHeroReady, setHeroReady] = useState(false);
  const [showLoader, setShowLoader] = useState(true);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex((prevIndex) => (prevIndex + 1) % images.length);
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
    <>
      <Header isIndexPage={true} />
      <div className="relative min-h-screen overflow-hidden bg-[#faf7f2]">
        {/* ローディング演出 */}
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

        {/* PC用画像: スライドショー */}
        {images.map((image, index) => (
          <div
            key={index}
            className={`absolute inset-0 hidden transition-opacity duration-1000 md:block ${
              index === currentIndex ? "opacity-100" : "opacity-0"
            }`}
          >
            <Image
              src={image.pc}
              alt={`slide-${index}`}
              fill
              style={{ objectFit: "cover" }}
              priority={index === 0}
              loading={index === 0 ? "eager" : undefined}
              onLoadingComplete={index === 0 ? handleHeroLoaded : undefined}
            />
          </div>
        ))}

        {/* スマホ用画像: 固定 */}
        <div className="absolute inset-0 md:hidden">
          <Image
            src={images[0].ph}
            alt="slide-fixed"
            fill
            style={{ objectFit: "cover", objectPosition: "center bottom" }}
            priority
            loading="eager"
            onLoadingComplete={handleHeroLoaded}
          />
        </div>
      </div>
    </>
  );
}
