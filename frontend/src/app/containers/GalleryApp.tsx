"use client"
import { ImageType } from '@/utils/types';
import { CategoryType } from '@/utils/types';
import { useState, useEffect } from 'react';
import { fetchImages } from '@/hooks/imageApi';
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

export default function GalleryApp() {
  // Filter
  const [categories, setCategories] = useState<CategoryType[]>([]);
  const [isLoadingCategories, setIsLoadingCategories] = useState<boolean>(true);
  // Grid
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<number[]>([]);
  const [images, setImages] = useState<ImageType[]>([]);
  const [isLoadingImages, setIsLoadingImages] = useState<boolean>(true);
  // Modal
  const [focusedImageIndex, setFocusedImageIndex] = useState<number | null>(null);
  const focusedImage = focusedImageIndex !== null ? images[focusedImageIndex] : null;

  const hasPrevious = focusedImageIndex !== null && focusedImageIndex > 0;
  const hasNext = focusedImageIndex !== null && focusedImageIndex < images.length - 1;
  const isInteractionDisabled = isLoadingCategories || isLoadingImages;

  async function loadCategories(){
    setIsLoadingCategories(true);
    try {
      const categoriesData = await fetchCategories();
      setCategories(categoriesData);
    } catch (error) {
      console.error('Failed to fetch categories:', error);
    } finally {
      setIsLoadingCategories(false);
    }
  }

  async function updateImages(categoryIds: number[]){
    setIsLoadingImages(true);
    try {
      const fetchedImages = await fetchImages({ categoryIds });
      setImages(fetchedImages);
    } catch (error) {
      console.error('Failed to fetch images:', error);
    } finally {
      setIsLoadingImages(false);
    }
  }

  function handleCategoryToggle(id: number) {
    if (isInteractionDisabled) {
      return;
    }
    setSelectedCategoryIds(
      (prev) =>
        prev.includes(id)
          ? prev.filter((categoryId) => categoryId !== id)
          : [...prev, id]
    );
    // ensure that the modal is closed when the category is changed
    setFocusedImageIndex(null);
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
        selectedCategoryIds={selectedCategoryIds}
        updateCategories={handleCategoryToggle}
        isDisabled={isInteractionDisabled}
      />
      <ImageGrid
        images={images}
        isLoading={isLoadingImages}
        onFocus={(index) => {
          if (isInteractionDisabled) {
            return;
          }
          setFocusedImageIndex(index);
        }}
      />
      <ImageModal
        image={focusedImage}
        onClose={() =>{
          setFocusedImageIndex(null)
        }}
        onNext={() => {
          if (isInteractionDisabled) {
            return;
          }
          setFocusedImageIndex((prev) =>
            prev !== null && prev < images.length - 1 ? prev + 1 : prev
          );
        }}
        onPrevious={() => {
          if (isInteractionDisabled) {
            return;
          }
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
