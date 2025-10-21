import React from "react";
import Header from "../components/layout/Header";
import GalleryApp from '../containers/GalleryApp';

export default function Page() {
  return (
    <>
      <Header heroTone="dark" />
      <div className="min-h-screen bg-[#faf7f2]">
        <GalleryApp />
      </div>
    </>
  );
}
