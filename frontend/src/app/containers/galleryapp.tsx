import { ImageType } from '@/utils/types';
import { use } from 'react';
import ImageGrid from '../components/image/imagegrid';

type Props = {
  categories: number[];
};

async function getImages(categories : number[]): Promise<ImageType[]> {
  const query = categories.length > 0 ? `?categories=${categories.join(',')}` : '';
  const url = `${process.env.NEXT_PUBLIC_API_BASE_URL}/images${query}`;
  console.log(url);
  const res = await fetch(url)
  if (!res.ok) {
    throw new Error("Failed to fetch data");
  }
  const ImagesData: ImageType[] = await res.json();
  return ImagesData;
}

export default function GalleryApp({categories}: Props) {
  const images = use(getImages(categories))
  return (
    <ImageGrid images={images} />
  );
}
