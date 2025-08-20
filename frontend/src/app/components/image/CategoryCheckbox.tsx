import { CategoryType } from '@/utils/types';

type CategoryCheckboxProps = {
  category: CategoryType;
  onCheck: (categoryId: number) => void;
};

export default function CategoryCheckbox({ category, onCheck }: CategoryCheckboxProps) {
  return (
    <label className="flex items-center gap-2 px-3 py-1.5 bg-white rounded-full shadow-sm hover:shadow transition-shadow cursor-pointer">
      <input
        type="checkbox"
        name={`${category.name}Checkbox`}
        onClick={() => onCheck(category.id)}
        className="w-4 h-4 rounded border-gray-300 text-gray-600 focus:ring-gray-500"
      />
      <span className="text-sm text-gray-700">{category.name}</span>
    </label>
  );
}
