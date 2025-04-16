export type ImageType = {
  id: number;
  title: string;
  caption: string;
  taken_at: string;
  camera_id: number;
  lens_id: number;
  display_order: number;
  is_published: boolean;
  created_at: string;
  updated_at: string;
  file: string; // 画像のURL
};
