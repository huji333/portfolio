export type ImageType = {
  id: number;
  title: string;
  caption: string;
  taken_at: string;
  camera_name: string;
  lens_name: string;
  row_order: number;
  is_published: boolean;
  file: string; // 画像のURL
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
  file: string | null;
  thumbnail?: string | null;
  width?: number | null;
  height?: number | null;
};
