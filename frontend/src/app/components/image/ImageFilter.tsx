import { CategoryType } from '@/utils/types';
import CategoryCheckbox from './categorycheckbox';

type Props = {
  categories: CategoryType[];
  updateCategories: (categoryId: number) => void;
}

export default function ImageFilter({categories, updateCategories = f => f}: Props) {
  return (
    <>
      {categories.map(category => (
        <CategoryCheckbox
          key={category.id}
          category={category}
          onCheck={()=>updateCategories(category.id)}
        />
      ))}
    </>
  );
}
