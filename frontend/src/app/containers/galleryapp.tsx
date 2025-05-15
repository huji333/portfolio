"use client"
import { ImageType } from '@/utils/types';
import { CategoryType } from '@/utils/types';
import { useState, useEffect } from 'react';
import ImageGrid from '../components/image/imagegrid';
import ImageFilter from '../components/image/ImageFilter';

type Props = {
  categories: number[];
};

async function fetchCategories(){
  const url = `${process.env.NEXT_PUBLIC_API_BASE_URL}/categories`;
  const res = await fetch(url);
  if (!res.ok){
    throw new Error("Failed to fetch categories.");
  }
  const categoriesData: CategoryType[] = await res.json()
  return categoriesData
}

async function fetchImages(categoryids : number[]): Promise<ImageType[]> {
  const query = categoryids.length > 0 ? `?categories=${categoryids.join(',')}` : '';
  const url = `${process.env.NEXT_PUBLIC_API_BASE_URL}/images${query}`;
  console.log(url);
  const res = await fetch(url)
  if (!res.ok) {
    throw new Error("Failed to fetch images");
  }
  const ImagesData: ImageType[] = await res.json();
  return ImagesData;
}


export default async function Gallerypp() {
  const categories = await fetchCategories();
  const [images, setImages] = useState<ImageType[]>([])
  const [selectedCategoryids, setSelectedCategoryids] = useState<number[]>([])

  console.log("page")

  async function updateImages(selectedCategoryids: number[]){
    const images = await fetchImages(selectedCategoryids)
    setImages(images)
  }

  useEffect( () => {
    updateImages(selectedCategoryids)
  },[selectedCategoryids]
  )

  return (
    <>
      <ImageFilter
        categories={categories}
        updateCategories={ (id) => {
          setSelectedCategoryids(
            (prev) =>
              prev.includes(id)
                ? prev.filter((categoryId) => categoryId !== id)
                : [...prev,id]
          )
        }}
      />
      <ImageGrid images={images} />
    </>
  );
}
