import { CategoryType } from '@/utils/types';

type CategoryCheckboxProps = {
  category: CategoryType;
  onCheck: (categoryId: number) => void;
  isChecked: boolean;
  isDisabled?: boolean;
};

export default function CategoryCheckbox({ category, onCheck, isChecked, isDisabled = false }: CategoryCheckboxProps) {
  const containerClasses = isDisabled
    ? 'flex items-center gap-2 px-3 py-1.5 bg-white rounded-full shadow-sm transition-opacity opacity-50 cursor-not-allowed'
    : 'flex items-center gap-2 px-3 py-1.5 bg-white rounded-full shadow-sm hover:shadow transition-shadow cursor-pointer';

  return (
    <label className={containerClasses}>
      <input
        type="checkbox"
        name={`${category.name}Checkbox`}
        checked={isChecked}
        onChange={() => onCheck(category.id)}
        disabled={isDisabled}
        className="w-4 h-4 rounded border-gray-300 text-gray-600 focus:ring-gray-500"
      />
      <span className="text-sm text-gray-700">{category.name}</span>
    </label>
  );
}
