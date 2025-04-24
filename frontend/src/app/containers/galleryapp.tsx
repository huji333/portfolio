import { ImageType } from '@/utils/types';
import Image from 'next/image';
import { use } from 'react';
import ImageGrid from '../components/image/imagegrid';

async function getImages(): Promise<ImageType[]> {
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/images`)
  if (!res.ok) {
    throw new Error("Failed to fetch data");
  }
  const ImagesData: ImageType[] = await res.json();
  return ImagesData;
}

export default function GalleryApp() {
  const images = use(getImages())
  return (
    <ImageGrid images={images} />
  );
}
