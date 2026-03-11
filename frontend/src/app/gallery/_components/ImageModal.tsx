'use client';

import { useEffect, useId, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import Image from 'next/image';
import { ImageType } from '@/utils/types';

const FOCUSABLE_SELECTORS =
  'button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])';

type Props = {
  image: ImageType | null;
  onClose: () => void;
  onNext: () => void;
  onPrevious: () => void;
  hasNext: boolean;
  hasPrevious: boolean;
};

export default function ImageModal({ image, onClose, onNext, onPrevious, hasNext, hasPrevious }: Props) {
  const dialogRef = useRef<HTMLDivElement | null>(null);
  const titleId = useId();
  const descriptionId = useId();
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
  }, []);

  useEffect(() => {
    if (!image || !isClient) {
      return undefined;
    }

    const dialogElement = dialogRef.current;
    if (!dialogElement) {
      return undefined;
    }

    const previouslyFocused = document.activeElement as HTMLElement | null;

    const focusFirstElement = () => {
      const focusable = dialogElement.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTORS);
      if (focusable.length > 0) {
        focusable[0].focus();
      } else {
        dialogElement.focus();
      }
    };

    focusFirstElement();

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        event.preventDefault();
        onClose();
        return;
      }

      if (event.key === 'ArrowRight' && hasNext) {
        event.preventDefault();
        onNext();
        return;
      }

      if (event.key === 'ArrowLeft' && hasPrevious) {
        event.preventDefault();
        onPrevious();
        return;
      }

      if (event.key === 'Tab') {
        const focusable = dialogElement.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTORS);

        if (focusable.length === 0) {
          event.preventDefault();
          dialogElement.focus();
          return;
        }

        const firstElement = focusable[0];
        const lastElement = focusable[focusable.length - 1];
        const activeElement = document.activeElement as HTMLElement | null;
        const isOutsideDialog = !activeElement || !dialogElement.contains(activeElement);

        if (event.shiftKey) {
          if (activeElement === firstElement || isOutsideDialog) {
            event.preventDefault();
            lastElement.focus();
          }
        } else if (activeElement === lastElement || isOutsideDialog) {
          event.preventDefault();
          firstElement.focus();
        }
      }
    };

    dialogElement.addEventListener('keydown', handleKeyDown);

    return () => {
      dialogElement.removeEventListener('keydown', handleKeyDown);
      previouslyFocused?.focus();
    };
  }, [image, hasNext, hasPrevious, isClient, onClose, onNext, onPrevious]);

  useEffect(() => {
    if (!image || !isClient) {
      return undefined;
    }

    const body = document.body;
    const previousOverflow = body.style.overflow;
    const previousPaddingRight = body.style.paddingRight;
    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;

    body.style.overflow = 'hidden';
    if (scrollbarWidth > 0) {
      body.style.paddingRight = `${scrollbarWidth}px`;
    }

    return () => {
      body.style.overflow = previousOverflow;
      body.style.paddingRight = previousPaddingRight;
    };
  }, [image, isClient]);

  if (!image || !isClient) return null;

  const captionId = image.caption ? descriptionId : undefined;

  const hasDimensions =
    typeof image.width === 'number' &&
    image.width > 0 &&
    typeof image.height === 'number' &&
    image.height > 0;

  const displayWidth = hasDimensions ? (image.width as number) : 1600;
  const displayHeight = hasDimensions ? (image.height as number) : 1066;

  const modalContent = (
    // Overlay
    <div
      ref={dialogRef}
      className="fixed inset-0 z-[80] flex items-center justify-center bg-black/70"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby={titleId}
      aria-describedby={captionId}
      tabIndex={-1}
    >
      {/* Close button */}
      <button
        type="button"
        aria-label="Close"
        className="absolute top-4 right-4 text-3xl text-white cursor-pointer select-none"
        onClick={(event) => {
          event.stopPropagation();
          onClose();
        }}
      >
        {'\u00D7'}
      </button>

      {/* Navigation zones — tall hit areas along left/right edges */}
      {hasPrevious && (
        <button
          type="button"
          aria-label="Previous"
          className="absolute left-0 top-0 bottom-0 w-16 sm:w-24 flex items-center justify-center cursor-pointer group"
          onClick={(event) => {
            event.stopPropagation();
            onPrevious();
          }}
        >
          <span className="flex h-10 w-10 items-center justify-center rounded-full bg-black/30 text-white transition group-hover:bg-black/60">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5} strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5"><polyline points="15 18 9 12 15 6" /></svg>
          </span>
        </button>
      )}
      {hasNext && (
        <button
          type="button"
          aria-label="Next"
          className="absolute right-0 top-0 bottom-0 w-16 sm:w-24 flex items-center justify-center cursor-pointer group"
          onClick={(event) => {
            event.stopPropagation();
            onNext();
          }}
        >
          <span className="flex h-10 w-10 items-center justify-center rounded-full bg-black/30 text-white transition group-hover:bg-black/60">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2.5} strokeLinecap="round" strokeLinejoin="round" className="h-5 w-5"><polyline points="9 6 15 12 9 18" /></svg>
          </span>
        </button>
      )}

      {/* Modal content */}
      <div
        className="relative w-full max-w-3xl max-h-[90vh] bg-white rounded shadow-lg flex flex-col overflow-hidden"
        onClick={(event) => {
          event.stopPropagation();
        }}
      >
        {/* Image container */}
        <div className="flex-1 min-h-0 p-2 flex items-center justify-center overflow-auto">
          <Image
            src={image.file}
            alt={image.title}
            width={displayWidth}
            height={displayHeight}
            sizes="(min-width: 1024px) 60vw, 90vw"
            className="h-auto max-h-[70vh] w-auto object-contain"
            priority={false}
          />
        </div>

        {/* Meta info */}
        <div className="px-4 pb-4 space-y-1 flex-shrink-0 break-words">
          <h3 id={titleId} className="text-lg font-semibold">
            {image.title}
          </h3>
          {image.caption && (
            <p id={captionId} className="text-sm text-gray-600">
              {image.caption}
            </p>
          )}
          <div className="flex flex-wrap gap-4 text-xs text-gray-500">
            {image.camera_name && <span>Camera: {image.camera_name}</span>}
            {image.lens_name && <span>Lens: {image.lens_name}</span>}
            {image.taken_at && (
              <span>
                {new Date(image.taken_at).toLocaleString('ja-JP', {
                  year: 'numeric',
                  month: '2-digit',
                  day: '2-digit',
                  hour: '2-digit',
                  minute: '2-digit',
                })}
              </span>
            )}
          </div>
        </div>
      </div>
    </div>
  );

  return createPortal(modalContent, document.body);
}
