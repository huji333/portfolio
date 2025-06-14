'use client';

import { ImageType } from '@/utils/types';
import Image from 'next/image';

type Props = {
  image: ImageType | null;
  onClose: () => void;
};

export default function ImageModal({ image, onClose }: Props) {
  if (!image) return null;

  return (
    // Overlay
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/70"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-label={image.title}
    >
      {/* Modal content */}
      <div
        className="relative max-w-3xl w-[90%] bg-white rounded shadow-lg"
        onClick={(e) => e.stopPropagation()} // prevent overlay click from closing
      >
        {/* Close button */}
        <button
          aria-label="Close"
          className="absolute top-2 right-2 text-2xl leading-none hover:opacity-75"
          onClick={onClose}
        >
          ×
        </button>

        {/* Image */}
        <div className="p-2">
          <Image
            src={image.file ?? image.url ?? ''} // adjust field name as needed
            alt={image.title}
            width={1200}
            height={800}
            className="w-full h-auto object-contain max-h-[80vh] rounded"
            priority
            unoptimized
          />
        </div>

        {/* Meta info */}
        <div className="px-4 pb-4 space-y-1">
          <h3 className="text-lg font-semibold">{image.title}</h3>
          {image.caption && <p className="text-sm text-gray-600">{image.caption}</p>}
          <div className="flex flex-wrap gap-4 text-xs text-gray-500">
            {image.camera_id && <span>Camera: {image.camera_id}</span>}
            {image.lens_id && <span>Lens: {image.lens_id}</span>}
            {image.taken_at && <span>{image.taken_at}</span>}
          </div>
        </div>
      </div>
    </div>
  );
}
