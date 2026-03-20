'use client';

import { type KeyboardEvent, useEffect, useRef, useState } from 'react';
import Image from 'next/image';
import { ImageType } from '@/utils/types';
import Loading from '@/ui/Loading';

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
  isInteractive?: boolean;
};

export default function ImageGrid({
  images,
  onFocus,
  isLoading = false,
  isInteractive = true,
}: ImageGridProps) {
  const containerRef = useRef<HTMLDivElement | null>(null);
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

  if (isLoading) {
    return <Loading label="Loading images..." className="py-20" />;
  }

  const isClickable = Boolean(onFocus) && isInteractive;
  const columnWidth = getColumnWidth(containerWidth);
  const gridStyles = { gridAutoRows: `${ROW_HEIGHT_PX}px` } as const;

  return (
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
              <Image
                src={image.thumbnail}
                alt={image.title}
                width={image.width as number}
                height={image.height as number}
                sizes="(min-width: 1024px) 33vw, (min-width: 640px) 50vw, 100vw"
                className="h-auto w-full"
                loading="lazy"
              />
            </div>
          </div>
        );
      })}
    </div>
  );
}
