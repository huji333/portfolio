import React, { Suspense } from "react";
import Header from "../components/layout/header";
import GalleryApp from '../containers/galleryapp';

const selectedCategories = [1, 2, 3, 4]; // Example categories

export default function Page() {
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
