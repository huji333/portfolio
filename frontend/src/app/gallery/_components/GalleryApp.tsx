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
  initialNextCursor?: string | null;
  initialHasMore?: boolean;
};

export default function GalleryApp({
  initialCategories: categories = [],
  initialImages = [],
  initialNextCursor = null,
  initialHasMore = false,
}: GalleryAppProps) {
  const [selectedCategoryIds, setSelectedCategoryIds] = useState<number[]>([]);
  const [images, setImages] = useState<ImageType[]>(initialImages);
  const [isLoadingImages, setIsLoadingImages] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [fetchError, setFetchError] = useState(false);
  const [nextCursor, setNextCursor] = useState<string | null>(initialNextCursor);
  const [hasMore, setHasMore] = useState(initialHasMore);
  const initialLoadRef = useRef(true);

  const [focusedImageIndex, setFocusedImageIndex] = useState<number | null>(null);
  const focusedImage = focusedImageIndex !== null ? images[focusedImageIndex] : null;

  const hasPrevious = focusedImageIndex !== null && focusedImageIndex > 0;
  const hasNext = focusedImageIndex !== null && focusedImageIndex < images.length - 1;
  const isInteractionDisabled = isLoadingImages;

  const isInteractionDisabledRef = useRef(isInteractionDisabled);
  const imagesLengthRef = useRef(images.length);

  useEffect(() => {
    isInteractionDisabledRef.current = isInteractionDisabled;
    imagesLengthRef.current = images.length;
  });

  // カテゴリ変更時: 1ページ目をロード
  useEffect(() => {
    if (initialLoadRef.current) {
      initialLoadRef.current = false;
      return;
    }

    let isActive = true;

    const load = async () => {
      setIsLoadingImages(true);
      setFetchError(false);

      try {
        const result = await fetchImages({ categoryIds: selectedCategoryIds });
        if (isActive) {
          setImages(result.images);
          setNextCursor(result.nextCursor);
          setHasMore(result.hasMore);
          setFetchError(result.error);
        }
      } finally {
        if (isActive) {
          setIsLoadingImages(false);
        }
      }
    };

    load();

    return () => {
      isActive = false;
    };
  }, [selectedCategoryIds]);

  // 次ページロード
  const loadMore = useCallback(async () => {
    if (isLoadingMore || !hasMore || !nextCursor) return;

    setIsLoadingMore(true);
    try {
      const result = await fetchImages({
        categoryIds: selectedCategoryIds,
        cursor: nextCursor,
      });
      if (!result.error) {
        setImages((prev) => [...prev, ...result.images]);
        setNextCursor(result.nextCursor);
        setHasMore(result.hasMore);
        setFetchError(false);
      } else {
        setFetchError(true);
      }
    } finally {
      setIsLoadingMore(false);
    }
  }, [isLoadingMore, hasMore, nextCursor, selectedCategoryIds]);

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
      {fetchError && (
        <p className="text-center text-sm text-red-600">読み込みに失敗しました。</p>
      )}
      <ImageGrid
        images={images}
        isLoading={isLoadingImages}
        isLoadingMore={isLoadingMore}
        hasMore={hasMore}
        onLoadMore={loadMore}
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
