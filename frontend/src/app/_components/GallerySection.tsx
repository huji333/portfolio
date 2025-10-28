
'use client';

import Link from 'next/link';
import ImageGrid from '@/app/gallery/_components/ImageGrid';
import { useImages } from './useImages';

export default function GallerySection() {
  const { images, isLoading } = useImages();
  const previewImages = images.slice(0, 9);
  const showEmptyState = !isLoading && previewImages.length === 0;

  return (
    <section className="bg-base-light px-6 py-20 md:py-24 snap-ignore" aria-labelledby="gallery-heading">
      <div className="mx-auto w-full max-w-5xl">
        <div className="flex flex-row items-center justify-between">
          <h2 id="gallery-heading" className="text-2xl font-semibold text-foreground md:text-3xl">
            作品集
          </h2>
          <Link
            href="/gallery"
            className="inline-flex items-center gap-2 text-sm font-medium text-foreground transition hover:text-blue-600"
          >
            Show More
            <span aria-hidden>→</span>
          </Link>
        </div>

        {showEmptyState ? (
          <p className="mt-10 text-sm text-foreground">表示できる写真がまだありません。</p>
        ) : (
          <div className="mt-10">
            <ImageGrid images={previewImages} isLoading={isLoading} isInteractive={false} />
          </div>
        )}
      </div>
    </section>
  );
}
