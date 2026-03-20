import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import Loading from './Loading';

describe('Loading', () => {
  it('renders with default label', () => {
    render(<Loading />);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('renders with custom label', () => {
    render(<Loading label="読み込み中" />);
    expect(screen.getByText('読み込み中')).toBeInTheDocument();
  });

  it('renders without label when null', () => {
    render(<Loading label={null} />);
    expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
  });

  it('has status role for accessibility', () => {
    render(<Loading />);
    expect(screen.getByRole('status')).toBeInTheDocument();
  });

  it('applies custom className', () => {
    render(<Loading className="min-h-screen" />);
    const container = screen.getByRole('status');
    expect(container.className).toContain('min-h-screen');
  });
});
