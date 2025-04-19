import { ImageType } from '@/utils/types';

type Props = {
  images: ImageType[];
};

export default function ImageGrid({ images }: Props) {
  return (
    <div className="columns-1 sm:columns-2 md:columns-3 gap-4">
      {images.map((image) => (
        <img
          key={image.id}
          src={image.file}
          alt={image.title}
          className="mb-3 break-inside-avoid shadow w-full h-auto"
        />
      ))}
    </div>
  );
}
