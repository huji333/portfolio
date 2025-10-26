
'use client';

import Link from 'next/link';
import ImageGrid from '@/app/gallery/_components/ImageGrid';
import { useImages } from '@/hooks/useImages';

export default function GallerySection() {
  const { images, isLoading } = useImages();
  const previewImages = images.slice(0, 9);
  const showEmptyState = !isLoading && previewImages.length === 0;

  return (
    <section className="bg-base-light px-6 py-20 md:py-24 snap-ignore" aria-labelledby="gallery-heading">
      <div className="mx-auto w-full max-w-5xl">
        <div className="flex flex-col gap-8 md:flex-row md:items-end md:justify-between">
          <div>
            <h2 id="gallery-heading" className="text-2xl font-bold text-black md:text-3xl">
              作品集
            </h2>
            <p className="mt-3 max-w-xl text-base font-medium text-black md:text-lg">
              最近撮影した写真を集めたギャラリーです
            </p>
          </div>
          <Link
            href="/gallery"
            className="inline-flex items-center gap-2 text-sm font-medium text-foreground transition hover:text-accent"
          >
            もっと見る
            <span aria-hidden>→</span>
          </Link>
        </div>

        {showEmptyState ? (
          <p className="mt-10 text-sm text-foreground">表示できる写真がまだありません。</p>
        ) : (
          <div className="mt-10">
            <ImageGrid images={previewImages} onFocus={() => {}} isLoading={isLoading} />
          </div>
        )}
      </div>
    </section>
  );
}
