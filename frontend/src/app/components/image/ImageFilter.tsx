import { CategoryType } from '@/utils/types';
import CategoryCheckbox from './categorycheckbox';

type Props = {
  categories: CategoryType[];
  updateCategories: (categoryId: number) => void;
}

export default function ImageFilter({categories, updateCategories }: Props) {
  return (
    <div className="flex flex-wrap gap-3 px-4">
      {categories.map(category => (
        <CategoryCheckbox
          key={category.id}
          category={category}
          onCheck={()=>updateCategories(category.id)}
        />
      ))}
    </div>
  );
}
