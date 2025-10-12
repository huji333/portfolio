"use client";

import { useImages } from '@/hooks/useImages';
import GalleryPreview from './GalleryPreview';

export default function AboutGallery() {
  const { images, isLoading } = useImages();
  const galleryImages = images.slice(0, 9);

  if (isLoading) {
    return (
      <div className="mt-10 flex justify-center">
        <span className="text-sm text-gray-500">読み込み中...</span>
      </div>
    );
  }

  if (galleryImages.length === 0) {
    return (
      <p className="mt-10 text-sm text-gray-500">表示できる写真がまだありません。</p>
    );
  }

  return (
    <div className="mt-10">
      <GalleryPreview images={galleryImages} />
    </div>
  );
}
