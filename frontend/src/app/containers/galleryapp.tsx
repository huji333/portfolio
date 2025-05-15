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

export default function Galleryapp() {
  const [categories, setCategories] = useState<CategoryType[]>([]);
  const [images, setImages] = useState<ImageType[]>([]);
  const [selectedCategoryids, setSelectedCategoryids] = useState<number[]>([]);

  async function loadCategories(){
    try {
      const categoriesData = await fetchCategories();
      setCategories(categoriesData);
    } catch (error) {
      console.error('Failed to fetch categories:', error);
    }
  }

  async function updateImages(selectedCategoryids: number[]){
    try {
      const images = await fetchImages(selectedCategoryids);
      setImages(images);
    } catch (error) {
      console.error('Failed to fetch images:', error);
    }
  }

  useEffect(() => {
    loadCategories();
  }, []);

  useEffect(() => {
    updateImages(selectedCategoryids);
  }, [selectedCategoryids]);

  return (
    <div className="space-y-6">
      <ImageFilter
        categories={categories}
        updateCategories={(id) => {
          setSelectedCategoryids(
            (prev) =>
              prev.includes(id)
                ? prev.filter((categoryId) => categoryId !== id)
                : [...prev, id]
          );
        }}
      />
      <ImageGrid images={images} />
    </div>
  );
}
