'use client';

import { useEffect, useState } from 'react';
import { fetchImages } from '@/hooks/imageApi';
import type { CategoryType, ImageType } from '@/utils/types';
import ImageFilter from './ImageFilter';
import ImageGrid from './ImageGrid';
import ImageModal from './ImageModal';
import { getApiBaseUrl } from '@/utils/api';

async function fetchCategories(): Promise<CategoryType[]> {
  const baseUrl = getApiBaseUrl();
  const response = await fetch(`${baseUrl}/categories`);

  if (!response.ok) {
    throw new Error('Failed to fetch categories.');
  }

  return response.json() as Promise<CategoryType[]>;
}

export default function GalleryApp() {
  const [categories, setCategories] = useState<CategoryType[]>([]);
  const [isLoadingCategories, setIsLoadingCategories] = useState(true);

  const [selectedCategoryIds, setSelectedCategoryIds] = useState<number[]>([]);
  const [images, setImages] = useState<ImageType[]>([]);
  const [isLoadingImages, setIsLoadingImages] = useState(true);

  const [focusedImageIndex, setFocusedImageIndex] = useState<number | null>(null);
  const focusedImage = focusedImageIndex !== null ? images[focusedImageIndex] : null;

  const hasPrevious = focusedImageIndex !== null && focusedImageIndex > 0;
  const hasNext = focusedImageIndex !== null && focusedImageIndex < images.length - 1;
  const isInteractionDisabled = isLoadingCategories || isLoadingImages;

  useEffect(() => {
    const loadCategories = async () => {
      setIsLoadingCategories(true);
      try {
        const categoriesData = await fetchCategories();
        setCategories(categoriesData);
      } catch (error) {
        console.error('Failed to fetch categories:', error);
      } finally {
        setIsLoadingCategories(false);
      }
    };

    void loadCategories();
  }, []);

  useEffect(() => {
    const updateImages = async (categoryIds: number[]) => {
      setIsLoadingImages(true);
      try {
        const fetchedImages = await fetchImages({ categoryIds });
        setImages(fetchedImages);
      } catch (error) {
        console.error('Failed to fetch images:', error);
      } finally {
        setIsLoadingImages(false);
      }
    };

    void updateImages(selectedCategoryIds);
  }, [selectedCategoryIds]);

  const handleCategoryToggle = (id: number) => {
    if (isInteractionDisabled) {
      return;
    }

    setSelectedCategoryIds((prev) =>
      prev.includes(id) ? prev.filter((categoryId) => categoryId !== id) : [...prev, id],
    );
    setFocusedImageIndex(null);
  };

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
        onClose={() => setFocusedImageIndex(null)}
        onNext={() => {
          if (isInteractionDisabled) {
            return;
          }
          setFocusedImageIndex((prev) => (prev !== null && prev < images.length - 1 ? prev + 1 : prev));
        }}
        onPrevious={() => {
          if (isInteractionDisabled) {
            return;
          }
          setFocusedImageIndex((prev) => (prev !== null && prev > 0 ? prev - 1 : prev));
        }}
        hasNext={hasNext}
        hasPrevious={hasPrevious}
      />
    </div>
  );
}
