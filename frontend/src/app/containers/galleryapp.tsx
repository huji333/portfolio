import { ImageType } from '@/utils/types';
import Image from 'next/image';
import { use } from 'react';

async function getImages(): Promise<ImageType[]> {
  const res = await fetch("http://localhost:3000/api/images")
  if (!res.ok) {
    throw new Error("Failed to fetch data");
  }
  const ImagesData: ImageType[] = await res.json();
  return ImagesData;
}

export default function GalleryApp() {
  const images = use(getImages())
  return (
    <div>
      {images.map((image) =>
        <Image
          key = { image.id }
          src = { image.file }
          alt = { image.title }
          width = {500}
          height = {400}
        />
      )}
    </div>
  );
}
