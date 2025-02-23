"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import Header from "./components/layout/header";

// 画像の配列（PC用とスマホ用）
const images = [
  { pc: "/index-pc.jpg", ph: "/index-ph.jpg" },
  { pc: "/index-pc-2.jpg", ph: "/index-ph-2.jpg" },
];

export default function Home() {
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex((prevIndex) => (prevIndex + 1) % images.length);
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <>
      <Header />
      <div className="relative min-h-screen overflow-hidden bg-[#faf7f2]">
        {/* PC用画像: スライドショー */}
        {images.map((image, index) => (
          <div
            key={index}
            className={`hidden md:block absolute inset-0 transition-opacity duration-1000 ${
              index === currentIndex ? "opacity-100" : "opacity-0"
            }`}
          >
            <Image
              src={image.pc}
              alt={`slide-${index}`}
              fill
              style={{ objectFit: "cover" }}
              priority
            />
          </div>
        ))}

        {/* スマホ用画像: 固定 */}
        <div className="md:hidden absolute inset-0">
          <Image
            src={images[0].ph}
            alt="slide-fixed"
            fill
            style={{ objectFit: "cover", objectPosition: "center bottom" }}
            priority
          />
        </div>
      </div>
    </>
  );
}
