import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ImageFilter from './ImageFilter';
import { CategoryType } from '@/utils/types';

const categories: CategoryType[] = [
  { id: 1, name: 'Landscape' },
  { id: 2, name: 'Portrait' },
  { id: 3, name: 'Street' },
];

describe('ImageFilter', () => {
  it('renders all categories', () => {
    render(<ImageFilter categories={categories} selectedCategoryIds={[]} onCategoryToggle={() => {}} />);
    expect(screen.getAllByRole('checkbox')).toHaveLength(3);
    expect(screen.getByText('Landscape')).toBeInTheDocument();
    expect(screen.getByText('Portrait')).toBeInTheDocument();
    expect(screen.getByText('Street')).toBeInTheDocument();
  });

  it('checks selected categories', () => {
    render(<ImageFilter categories={categories} selectedCategoryIds={[1, 3]} onCategoryToggle={() => {}} />);
    const checkboxes = screen.getAllByRole('checkbox');
    expect(checkboxes[0]).toBeChecked();
    expect(checkboxes[1]).not.toBeChecked();
    expect(checkboxes[2]).toBeChecked();
  });

  it('calls onCategoryToggle when checkbox is toggled', async () => {
    const user = userEvent.setup();
    const onCategoryToggle = vi.fn();
    render(<ImageFilter categories={categories} selectedCategoryIds={[]} onCategoryToggle={onCategoryToggle} />);

    await user.click(screen.getByText('Portrait'));
    expect(onCategoryToggle).toHaveBeenCalledWith(2);
  });

  it('disables all checkboxes when isDisabled is true', () => {
    render(<ImageFilter categories={categories} selectedCategoryIds={[]} onCategoryToggle={() => {}} isDisabled />);
    screen.getAllByRole('checkbox').forEach(cb => {
      expect(cb).toBeDisabled();
    });
  });
});
