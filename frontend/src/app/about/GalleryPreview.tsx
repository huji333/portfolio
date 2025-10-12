"use client";

import ImageGrid from '../components/image/ImageGrid';
import { ImageType } from '@/utils/types';

type GalleryPreviewProps = {
  images: ImageType[];
};

export default function GalleryPreview({ images }: GalleryPreviewProps) {
  return (
    <ImageGrid
      images={images}
      onFocus={() => {
        /* Modal is disabled for the about page preview */
      }}
    />
  );
}
