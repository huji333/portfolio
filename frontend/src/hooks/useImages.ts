"use client";

import { useEffect, useMemo, useState } from 'react';
import { ImageType } from '@/utils/types';
import { fetchImages } from './imageApi';

type UseImagesOptions = {
  categoryIds?: number[];
};

type UseImagesResult = {
  images: ImageType[];
  isLoading: boolean;
};

export function useImages({ categoryIds = [] }: UseImagesOptions = {}): UseImagesResult {
  const [images, setImages] = useState<ImageType[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const categoryKey = useMemo(() => {
    return [...categoryIds].sort((a, b) => a - b).join(',');
  }, [categoryIds]);

  useEffect(() => {
    let isActive = true;
    setIsLoading(true);

    fetchImages({ categoryIds })
      .then((fetchedImages) => {
        if (!isActive) {
          return;
        }
        setImages(fetchedImages);
      })
      .catch((error) => {
        if (!isActive) {
          return;
        }
        console.error('useImages failed to fetch images', error);
        setImages([]);
      })
      .finally(() => {
        if (isActive) {
          setIsLoading(false);
        }
      });

    return () => {
      isActive = false;
    };
  }, [categoryKey]);

  return { images, isLoading };
}
