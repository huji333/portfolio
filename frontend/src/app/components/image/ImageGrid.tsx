import { ImageType } from '@/utils/types';

type ImageGridProps = {
  images: ImageType[];
  onFocus: (imageIndex: number) => void;
};

export default function ImageGrid({ images, onFocus }: ImageGridProps) {
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
