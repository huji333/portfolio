import React, { useState, useEffect, use, Suspense } from "react";
import Image from "next/image";
import {ImageType} from "@utils/types";
import Header from "../components/layout/header";
import GalleryApp from '../containers/galleryapp';



export default function Page() {
  return (
    <div className="min-h-screen bg-[#faf7f2]">
      <Header />
      <Suspense>
        <GalleryApp />
      </Suspense>
    </div>
  );
}
