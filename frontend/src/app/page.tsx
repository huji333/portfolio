import Image from "next/image";
import Header from ".//components/layout/header"

export default function Home() {
  return (

    <>
      <Header />

      <div className="relative h-screen bg-cover bg-center bg-[url('/index-ph.jpg')] md:bg-[url('/index-pc.jpg')]">
        <div className="absolute top-1/4 left-1/2 transform -translate-x-1/2 md:hidden">
          <h1 className="text-6xl font-bold text-black">Kakemu FUJII</h1>
        </div>
        <div className="hidden md:flex absolute inset-0 items-center justify-center">
          <h1 className="text-6xl font-bold text-white drop-shadow-lg">
            Kakemu FUJII
          </h1>
        </div>
      </div>
    </>


  );
}
