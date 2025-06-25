export type ImageType = {
  id: number;
  title: string;
  caption: string;
  taken_at: string;
  camera_name: string;
  lens_name: string;
  row_order: number;
  is_published: boolean;
  created_at: string;
  updated_at: string;
  file: string; // 画像のURL
};

export type CategoryType = {
  id: number;
  name: string;
  created_at: string;
  updated_at: string;
};
