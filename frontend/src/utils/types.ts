export type ImageType = {
  id: number;
  title: string;
  caption: string;
  taken_at: string | null;
  camera_name: string | null;
  lens_name: string | null;
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
