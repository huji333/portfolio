"use client"
import { ImageType } from '@/utils/types';
import { CategoryType } from '@/utils/types';
import { use, useState, useEffect } from 'react';
import ImageGrid from '../components/image/imagegrid';
import CategoryCheckboxList from '../components/image/categorycheckboxlist';

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

async function fetchImages(categories : number[]): Promise<ImageType[]> {
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


export default function Gallerypp() {
  const [selectedCategories, setSelectedCategories] = useState<number[]>([]);
  const [images, setImages] = useState<ImageType[]>([])
  const [categories, setCategories] = useState<number[]>([])

  console.log("page")

  async function updateImages(categoryids: number[]){
    const images = await fetchImages(categoryids)
    setImages(images)
  }

  useEffect( () => {
    updateImages(categories)
  },[]
  )

  return (
    <ImageGrid images={images} />
  );
}
