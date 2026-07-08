export type ImageType = {
  id: number;
  title: string;
  caption: string | null;
  taken_at: string | null;
  camera_name: string | null;
  lens_name: string | null;
  file: string;
  thumbnail?: string | null;
  width: number | null;
  height: number | null;
};

export type PaginatedImages = {
  images: ImageType[];
  next_cursor: string | null;
  has_more: boolean;
};

export type CategoryType = {
  id: number;
  name: string;
};

export type ProjectType = {
  id: number;
  title: string;
  link: string;
  description: string | null;
  tags: string[];
  file: string | null;
  thumbnail?: string | null;
  width?: number | null;
  height?: number | null;
};
