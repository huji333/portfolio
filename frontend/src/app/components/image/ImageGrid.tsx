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
      {images.map((image, index) => (
        <img
          key={image.id}
          src={image.file}
          alt={image.title}
          className="mb-3 break-inside-avoid shadow w-full h-auto cursor-pointer"
          onClick={() => onFocus(index)}
        />
      ))}
    </div>
  );
}
