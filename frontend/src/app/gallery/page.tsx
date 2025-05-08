import React, { Suspense } from "react";
import { useState } from 'react';
import Header from "../components/layout/header";
import GalleryApp from '../containers/galleryapp';


export default function Page() {
  const [selectedCategories, setSelectedCategories] = useState<number[]>([]);
  return (
    <>
      <Header />
      <div className="min-h-screen bg-[#faf7f2] pt-[80px]">
        <Suspense>
          <GalleryApp categories={selectedCategories} />
        </Suspense>
      </div>
    </>
  );
}
