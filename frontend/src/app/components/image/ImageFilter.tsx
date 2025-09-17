import { CategoryType } from '@/utils/types';
import CategoryCheckbox from './CategoryCheckbox';

type ImageFilterProps = {
  categories: CategoryType[];
  selectedCategoryIds: number[];
  updateCategories: (categoryId: number) => void;
  isDisabled?: boolean;
};

export default function ImageFilter({ categories, selectedCategoryIds, updateCategories, isDisabled = false }: ImageFilterProps) {
  return (
    <div className="flex flex-wrap gap-3 px-4">
      {categories.map(category => (
        <CategoryCheckbox
          key={category.id}
          category={category}
          onCheck={updateCategories}
          isChecked={selectedCategoryIds.includes(category.id)}
          isDisabled={isDisabled}
        />
      ))}
    </div>
  );
}
