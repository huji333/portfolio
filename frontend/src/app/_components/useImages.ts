'use client';

import { useEffect, useMemo, useState } from 'react';
import { ImageType } from '@/utils/types';
import { fetchImages } from '@/hooks/imageApi';

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

    const normalizedCategoryIds =
      categoryKey.length > 0
        ? categoryKey
            .split(',')
            .map((value) => Number.parseInt(value, 10))
            .filter((value) => Number.isFinite(value))
        : [];

    const load = async () => {
      setIsLoading(true);
      try {
        const result = await fetchImages({ categoryIds: normalizedCategoryIds });
        if (isActive) {
          setImages(result.images);
        }
      } finally {
        if (isActive) {
          setIsLoading(false);
        }
      }
    };

    load();

    return () => {
      isActive = false;
    };
  }, [categoryKey]);

  return { images, isLoading };
}
