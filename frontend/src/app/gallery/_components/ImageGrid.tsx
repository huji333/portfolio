'use client';

import Image from 'next/image';
import { ImageType } from '@/utils/types';

type ImageGridProps = {
  images: ImageType[];
  onFocus: (imageIndex: number) => void;
  isLoading?: boolean;
};

export default function ImageGrid({ images, onFocus, isLoading = false }: ImageGridProps) {
  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="h-12 w-12 animate-spin rounded-full border-4 border-neutral-200 border-t-neutral-600" />
      </div>
    );
  }

  return (
    <div className="columns-1 sm:columns-2 md:columns-3 gap-4">
      {images.map((image, index) => {
        const handleFocus = () => onFocus(index);
        const hasDimensions =
          typeof image.width === 'number' && typeof image.height === 'number' && image.width > 0 && image.height > 0;

        if (!hasDimensions) {
          return null;
        }

        return (
          <div
            key={image.id}
            className="mb-3 break-inside-avoid cursor-pointer shadow"
            onClick={handleFocus}
            role="button"
            tabIndex={0}
            aria-label={image.title}
            onKeyDown={(event) => {
              if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                handleFocus();
              }
            }}
          >
            <Image
              src={image.file}
              alt={image.title}
              width={image.width as number}
              height={image.height as number}
              sizes="(min-width: 1024px) 33vw, (min-width: 640px) 50vw, 100vw"
              className="w-full h-auto"
              loading="lazy"
            />
          </div>
        );
      })}
    </div>
  );
}
