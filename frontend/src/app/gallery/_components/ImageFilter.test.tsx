import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ImageFilter from './ImageFilter';
import { CategoryType } from '@/utils/types';

const categories: CategoryType[] = [
  { id: 1, name: 'Landscape', created_at: '', updated_at: '' },
  { id: 2, name: 'Portrait', created_at: '', updated_at: '' },
  { id: 3, name: 'Street', created_at: '', updated_at: '' },
];

describe('ImageFilter', () => {
  it('renders all categories', () => {
    render(<ImageFilter categories={categories} selectedCategoryIds={[]} updateCategories={() => {}} />);
    expect(screen.getAllByRole('checkbox')).toHaveLength(3);
    expect(screen.getByText('Landscape')).toBeInTheDocument();
    expect(screen.getByText('Portrait')).toBeInTheDocument();
    expect(screen.getByText('Street')).toBeInTheDocument();
  });

  it('checks selected categories', () => {
    render(<ImageFilter categories={categories} selectedCategoryIds={[1, 3]} updateCategories={() => {}} />);
    const checkboxes = screen.getAllByRole('checkbox');
    expect(checkboxes[0]).toBeChecked();
    expect(checkboxes[1]).not.toBeChecked();
    expect(checkboxes[2]).toBeChecked();
  });

  it('calls updateCategories when checkbox is toggled', async () => {
    const user = userEvent.setup();
    const updateCategories = vi.fn();
    render(<ImageFilter categories={categories} selectedCategoryIds={[]} updateCategories={updateCategories} />);

    await user.click(screen.getByText('Portrait'));
    expect(updateCategories).toHaveBeenCalledWith(2);
  });

  it('disables all checkboxes when isDisabled is true', () => {
    render(<ImageFilter categories={categories} selectedCategoryIds={[]} updateCategories={() => {}} isDisabled />);
    screen.getAllByRole('checkbox').forEach(cb => {
      expect(cb).toBeDisabled();
    });
  });
});
