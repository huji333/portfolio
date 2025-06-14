"use client"
import { ImageType } from '@/utils/types';
import { CategoryType } from '@/utils/types';
import { useState, useEffect } from 'react';
import ImageGrid from '../components/image/ImageGrid';
import ImageFilter from '../components/image/ImageFilter';
import ImageModal from '../components/image/ImageModal';

async function fetchCategories(){
  const url = `${process.env.NEXT_PUBLIC_API_BASE_URL}/categories`;
  const res = await fetch(url);
  if (!res.ok){
    throw new Error("Failed to fetch categories.");
  }
  const categoriesData: CategoryType[] = await res.json()
  return categoriesData
}

async function fetchImages(categoryIds : number[]): Promise<ImageType[]> {
  const query = categoryIds.length > 0 ? `?categories=${categoryIds.join(',')}` : '';
  const url = `${process.env.NEXT_PUBLIC_API_BASE_URL}/images${query}`;
  const res = await fetch(url)
  if (!res.ok) {
    throw new Error("Failed to fetch images");
  }
  const imagesData: ImageType[] = await res.json();
  return imagesData;
}

export default function Galleryapp() {
  // Filter
  const [categories, setCategories] = useState<CategoryType[]>([]);
  // Grid
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<number[]>([]);
  const [images, setImages] = useState<ImageType[]>([]);
  // Modal
  const [focusedImageIndex, setFocusedImageIndex] = useState<number | null>(null);
  const focusedImage = focusedImageIndex !== null ? images[focusedImageIndex] : null;

  const hasPrevious = focusedImageIndex !== null && focusedImageIndex > 0;
  const hasNext = focusedImageIndex !== null && focusedImageIndex < images.length - 1;

  async function loadCategories(){
    try {
      const categoriesData = await fetchCategories();
      setCategories(categoriesData);
    } catch (error) {
      console.error('Failed to fetch categories:', error);
    }
  }

  async function updateImages(categoryIds: number[]){
    try {
      const fetchedImages = await fetchImages(categoryIds);
      setImages(fetchedImages);
    } catch (error) {
      console.error('Failed to fetch images:', error);
    }
  }

  useEffect(() => {
    loadCategories();
  }, []);

  useEffect(() => {
    updateImages(selectedCategoryIds);
  }, [selectedCategoryIds]);

  return (
    <div className="space-y-6">
      <ImageFilter
        categories={categories}
        updateCategories={(id) => {
          setSelectedCategoryIds(
            (prev) =>
              prev.includes(id)
                ? prev.filter((categoryId) => categoryId !== id)
                : [...prev, id]
          );
          // ensure that the modal is closed when the category is changed
          setFocusedImageIndex(null);
        }}
      />
      <ImageGrid
        images={images}
        onFocus={(index) => {
          console.log('onFocus called with index:', index);
          setFocusedImageIndex(index);
        }}
      />
      <ImageModal
        image={focusedImage}
        onClose={() =>{
          setFocusedImageIndex(null)
        }}
        onNext={() => {
          setFocusedImageIndex((prev) =>
            prev !== null && prev < images.length - 1 ? prev + 1 : prev
          );
        }}
        onPrevious={() => {
          setFocusedImageIndex((prev) =>
            prev !== null && prev > 0 ? prev - 1 : prev
          );
        }}
        hasNext={hasNext}
        hasPrevious={hasPrevious}
      />
    </div>
  );
}
