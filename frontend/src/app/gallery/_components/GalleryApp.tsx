'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
import { fetchImages } from '@/hooks/imageApi';
import type { CategoryType, ImageType } from '@/utils/types';
import ImageFilter from './ImageFilter';
import ImageGrid from './ImageGrid';
import ImageModal from './ImageModal';

type GalleryAppProps = {
  initialCategories?: CategoryType[];
  initialImages?: ImageType[];
};

export default function GalleryApp({ initialCategories: categories = [], initialImages = [] }: GalleryAppProps) {
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<number[]>([]);
  const [images, setImages] = useState<ImageType[]>(initialImages);
  const [isLoadingImages, setIsLoadingImages] = useState(false);
  const initialLoadRef = useRef(true);

  const [focusedImageIndex, setFocusedImageIndex] = useState<number | null>(null);
  const focusedImage = focusedImageIndex !== null ? images[focusedImageIndex] : null;

  const hasPrevious = focusedImageIndex !== null && focusedImageIndex > 0;
  const hasNext = focusedImageIndex !== null && focusedImageIndex < images.length - 1;
  const isInteractionDisabled = isLoadingImages;

  const isInteractionDisabledRef = useRef(isInteractionDisabled);
  isInteractionDisabledRef.current = isInteractionDisabled;
  const imagesLengthRef = useRef(images.length);
  imagesLengthRef.current = images.length;

  useEffect(() => {
    if (initialLoadRef.current) {
      initialLoadRef.current = false;
      return;
    }

    let isActive = true;
    setIsLoadingImages(true);

    fetchImages({ categoryIds: selectedCategoryIds })
      .then((fetchedImages) => {
        if (isActive) {
          setImages(fetchedImages);
        }
      })
      .catch((error) => {
        if (isActive) {
          console.error('Failed to fetch images:', error);
        }
      })
      .finally(() => {
        if (isActive) {
          setIsLoadingImages(false);
        }
      });

    return () => {
      isActive = false;
    };
  }, [selectedCategoryIds]);

  const handleCategoryToggle = useCallback((id: number) => {
    if (isInteractionDisabledRef.current) {
      return;
    }

    setSelectedCategoryIds((prev) =>
      prev.includes(id) ? prev.filter((categoryId) => categoryId !== id) : [...prev, id],
    );
    setFocusedImageIndex(null);
  }, []);

  const handleFocus = useCallback((index: number) => {
    if (isInteractionDisabledRef.current) {
      return;
    }
    setFocusedImageIndex(index);
  }, []);

  const handleClose = useCallback(() => setFocusedImageIndex(null), []);

  const handleNext = useCallback(() => {
    if (isInteractionDisabledRef.current) {
      return;
    }
    setFocusedImageIndex((prev) => (prev !== null && prev < imagesLengthRef.current - 1 ? prev + 1 : prev));
  }, []);

  const handlePrevious = useCallback(() => {
    if (isInteractionDisabledRef.current) {
      return;
    }
    setFocusedImageIndex((prev) => (prev !== null && prev > 0 ? prev - 1 : prev));
  }, []);

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
        onFocus={handleFocus}
      />
      <ImageModal
        image={focusedImage}
        onClose={handleClose}
        onNext={handleNext}
        onPrevious={handlePrevious}
        hasNext={hasNext}
        hasPrevious={hasPrevious}
      />
    </div>
  );
}
