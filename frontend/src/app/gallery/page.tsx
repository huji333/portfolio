import React, { Suspense } from "react";
import Header from "../components/layout/header";
import GalleryApp from '../containers/galleryapp';



export default function Page() {
  return (

    <>
      <div className="w-full h-auto bg-[#faf7f2]">
        <Header />
      </div>
      <div className="min-h-screen bg-[#faf7f2]">
        <Suspense>
          <GalleryApp />
        </Suspense>
      </div>
    </>
  );
}
