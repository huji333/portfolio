'use client';

import { type KeyboardEvent, type SyntheticEvent, useCallback, useEffect, useRef, useState } from 'react';
import Image from 'next/image';
import { ImageType } from '@/utils/types';
import Loading from '@/ui/Loading';

function GridImage({ src, fallbackSrc, alt, width, height }: {
  src: string;
  fallbackSrc: string;
  alt: string;
  width: number;
  height: number;
}) {
  const [currentSrc, setCurrentSrc] = useState(src);

  const handleError = useCallback(
    (e: SyntheticEvent<HTMLImageElement>) => {
      if (currentSrc !== fallbackSrc) {
        setCurrentSrc(fallbackSrc);
      } else {
        (e.target as HTMLImageElement).style.display = 'none';
      }
    },
    [currentSrc, fallbackSrc],
  );

  return (
    <Image
      src={currentSrc}
      alt={alt}
      width={width}
      height={height}
      sizes="(min-width: 1024px) 33vw, (min-width: 640px) 50vw, 100vw"
      className="h-auto w-full"
      loading="lazy"
      onError={handleError}
    />
  );
}

const GRID_GAP_PX = 16; // matches Tailwind gap-4
const ROW_HEIGHT_PX = 8; // base row height for masonry grid
const ROW_UNIT_PX = ROW_HEIGHT_PX + GRID_GAP_PX;
const DEFAULT_COLUMN_WIDTH = 320;

const getColumnCount = (width?: number) => {
  if (!width || width < 640) {
    return 1;
  }

  if (width < 768) {
    return 2;
  }

  return 3;
};

const getColumnWidth = (containerWidth?: number) => {
  const columnCount = getColumnCount(containerWidth);

  if (!containerWidth) {
    return DEFAULT_COLUMN_WIDTH;
  }

  const totalGap = GRID_GAP_PX * (columnCount - 1);
  const width = (containerWidth - totalGap) / columnCount;

  return Math.max(width, ROW_HEIGHT_PX);
};

const getRowSpan = (imageWidth: number, imageHeight: number, columnWidth: number) => {
  const ratio = imageHeight / imageWidth;
  const span = Math.ceil(((ratio * columnWidth) + GRID_GAP_PX) / ROW_UNIT_PX);

  return Number.isFinite(span) && span > 0 ? span : 1;
};

type ImageGridProps = {
  images: ImageType[];
  onFocus?: (imageIndex: number) => void;
  isLoading?: boolean;
  isLoadingMore?: boolean;
  hasMore?: boolean;
  onLoadMore?: () => void;
  isInteractive?: boolean;
};

export default function ImageGrid({
  images,
  onFocus,
  isLoading = false,
  isLoadingMore = false,
  hasMore = false,
  onLoadMore,
  isInteractive = true,
}: ImageGridProps) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const sentinelRef = useRef<HTMLDivElement | null>(null);
  const [containerWidth, setContainerWidth] = useState<number>();

  useEffect(() => {
    const element = containerRef.current;
    if (!element) {
      return undefined;
    }

    setContainerWidth(element.getBoundingClientRect().width);

    const observer = new ResizeObserver((entries) => {
      const [entry] = entries;
      if (entry) {
        setContainerWidth(entry.contentRect.width);
      }
    });

    observer.observe(element);

    return () => observer.disconnect();
  }, [isLoading]);

  // IntersectionObserver for infinite scroll
  useEffect(() => {
    const sentinel = sentinelRef.current;
    if (!sentinel || !hasMore || !onLoadMore) {
      return undefined;
    }

    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0]?.isIntersecting) {
          onLoadMore();
        }
      },
      { rootMargin: '200px' },
    );

    observer.observe(sentinel);

    return () => observer.disconnect();
  }, [hasMore, onLoadMore]);

  if (isLoading) {
    return <Loading label="Loading images..." className="py-20" />;
  }

  const isClickable = Boolean(onFocus) && isInteractive;
  const columnWidth = getColumnWidth(containerWidth);
  const gridStyles = { gridAutoRows: `${ROW_HEIGHT_PX}px` } as const;

  return (
    <>
      <div
        ref={containerRef}
        className="grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-3"
        style={gridStyles}
      >
        {images.map((image, index) => {
          const handleFocus = () => onFocus?.(index);
          const hasDimensions =
            typeof image.width === 'number' && typeof image.height === 'number' && image.width > 0 && image.height > 0;

          if (!hasDimensions || !image.thumbnail) {
            return null;
          }

          const rowSpan = getRowSpan(image.width as number, image.height as number, columnWidth);
          const containerClassName = isClickable ? 'cursor-pointer' : '';
          const itemStyle = { gridRowEnd: `span ${rowSpan}` } as const;

          const interactionProps = isClickable
            ? {
                role: 'button' as const,
                tabIndex: 0,
                'aria-label': image.title,
                onClick: handleFocus,
                onKeyDown: (event: KeyboardEvent<HTMLDivElement>) => {
                  if (event.key === 'Enter' || event.key === ' ') {
                    event.preventDefault();
                    handleFocus();
                  }
                },
              }
            : {};

          return (
            <div key={image.id} className={containerClassName} style={itemStyle} {...interactionProps}>
              <div className="overflow-hidden bg-white shadow-sm">
                <GridImage
                  src={image.thumbnail}
                  fallbackSrc={image.file}
                  alt={image.title}
                  width={image.width as number}
                  height={image.height as number}
                />
              </div>
            </div>
          );
        })}
      </div>
      {hasMore && (
        <div ref={sentinelRef} className="flex justify-center py-8">
          {isLoadingMore && <Loading label="Loading more..." />}
        </div>
      )}
    </>
  );
}
