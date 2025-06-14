'use client';

import { ImageType } from '@/utils/types';

type Props = {
  image: ImageType | null;
  onClose: () => void;
  onNext: () => void;
  onPrevious: () => void;
  hasNext: boolean;
  hasPrevious: boolean;
};

export default function ImageModal({ image, onClose, onNext, onPrevious, hasNext, hasPrevious }: Props) {
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
      {/* Close icon */}
      <div
        aria-label="Close"
        className="absolute top-4 right-4 text-3xl text-white cursor-pointer select-none"
        onClick={onClose}
      >
        {'\u00D7'}
      </div>

      {/* Previous and next buttons */}
      {hasPrevious && (
        <div
          aria-label="Previous"
          className="absolute left-4 top-1/2 -translate-y-1/2 text-4xl text-white cursor-pointer select-none"
          onClick={(e) => {
            e.stopPropagation();
            onPrevious();
          }}
        >
          {'\u2039'}
        </div>
      )}
      {hasNext && (
        <div
          aria-label="Next"
          className="absolute right-4 top-1/2 -translate-y-1/2 text-4xl text-white cursor-pointer select-none"
          onClick={(e) => {
            e.stopPropagation();
            onNext();
          }}
        >
          {'\u203A'}
        </div>
      )}

      {/* Modal content */}
      <div
        className="relative w-full max-w-3xl max-h-[90vh] bg-white rounded shadow-lg flex flex-col overflow-hidden"
        onClick={(e) => e.stopPropagation()} // prevent overlay click from closing
      >
        {/* Image container */}
        <div className="flex-1 min-h-0 p-2 flex items-center justify-center overflow-auto">
          <img
            src={image.file}
            alt={image.title}
            className="max-h-[70vh] max-w-full w-auto h-auto object-contain"
          />
        </div>

        {/* Meta info */}
        <div className="px-4 pb-4 space-y-1 flex-shrink-0 break-words">
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
