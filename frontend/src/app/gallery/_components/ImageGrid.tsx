'use client';

import type { KeyboardEvent } from 'react';
import Image from 'next/image';
import { ImageType } from '@/utils/types';

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
  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="h-12 w-12 animate-spin rounded-full border-4 border-neutral-200 border-t-neutral-600" />
      </div>
    );
  }

  const isClickable = Boolean(onFocus) && isInteractive;

  return (
    <div className="columns-1 sm:columns-2 md:columns-3 gap-4">
      {images.map((image, index) => {
        const handleFocus = () => onFocus?.(index);
        const hasDimensions =
          typeof image.width === 'number' && typeof image.height === 'number' && image.width > 0 && image.height > 0;

        if (!hasDimensions) {
          return null;
        }

        const containerClassName = `mb-3 break-inside-avoid shadow${isClickable ? ' cursor-pointer' : ''}`;

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
          <div key={image.id} className={containerClassName} {...interactionProps}>
            <Image
              src={image.file}
              alt={image.title}
              width={image.width as number}
              height={image.height as number}
              sizes="(min-width: 1024px) 33vw, (min-width: 640px) 50vw, 100vw"
              className="h-auto w-full"
              loading="lazy"
            />
          </div>
        );
      })}
    </div>
  );
}
