import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import GalleryApp from './GalleryApp';
import type { ImageType } from '@/utils/types';

const image: ImageType = {
  id: 1,
  title: 'Mountain',
  caption: null,
  taken_at: null,
  camera_name: null,
  lens_name: null,
  file: '/mountain.jpg',
  thumbnail: '/mountain-thumb.jpg',
  width: 800,
  height: 600,
};

describe('GalleryApp', () => {
  it('shows empty state message when there are no images', () => {
    render(<GalleryApp />);
    expect(screen.getByText('表示できる写真がまだありません。')).toBeInTheDocument();
  });

  it('does not show empty state message when initialImages is provided', () => {
    render(<GalleryApp initialImages={[image]} />);
    expect(screen.queryByText('表示できる写真がまだありません。')).not.toBeInTheDocument();
  });

  it('shows fetch error message and not the empty state message when initialFetchError is true', () => {
    render(<GalleryApp initialFetchError />);
    expect(screen.getByText('読み込みに失敗しました。')).toBeInTheDocument();
    expect(screen.queryByText('表示できる写真がまだありません。')).not.toBeInTheDocument();
  });
});
