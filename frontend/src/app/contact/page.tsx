import React from "react";
import Header from "../components/layout/Header";

export default function Page() {
  return (
    <>
      <Header />
      <main className="min-h-screen bg-[#faf7f2] flex flex-col items-center justify-center px-6 text-center">
        <span className="text-xs tracking-[0.3em] text-gray-500 uppercase">Contact</span>
        <h1 className="mt-4 text-3xl md:text-4xl font-semibold text-gray-900">Work in Progress</h1>
        <p className="mt-6 max-w-md text-base md:text-lg text-gray-600">お問い合わせページは現在作成中です。</p>
      </main>
    </>
  );
}
