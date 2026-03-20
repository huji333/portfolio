import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import CategoryCheckbox from './CategoryCheckbox';
import { CategoryType } from '@/utils/types';

const category: CategoryType = {
  id: 1,
  name: 'Landscape',
  created_at: '2025-01-01',
  updated_at: '2025-01-01',
};

describe('CategoryCheckbox', () => {
  it('renders category name', () => {
    render(<CategoryCheckbox category={category} onCheck={() => {}} isChecked={false} />);
    expect(screen.getByText('Landscape')).toBeInTheDocument();
  });

  it('reflects checked state', () => {
    render(<CategoryCheckbox category={category} onCheck={() => {}} isChecked={true} />);
    expect(screen.getByRole('checkbox')).toBeChecked();
  });

  it('calls onCheck with category id when clicked', async () => {
    const user = userEvent.setup();
    const onCheck = vi.fn();
    render(<CategoryCheckbox category={category} onCheck={onCheck} isChecked={false} />);

    await user.click(screen.getByRole('checkbox'));
    expect(onCheck).toHaveBeenCalledWith(1);
  });

  it('is disabled when isDisabled is true', () => {
    render(<CategoryCheckbox category={category} onCheck={() => {}} isChecked={false} isDisabled />);
    expect(screen.getByRole('checkbox')).toBeDisabled();
  });
});
