import { CategoryType } from '@/utils/types';
import CategoryCheckbox from './categorycheckbox';

type Props = {
  categories: CategoryType[];
  selectedCategories: number[];
}

export default function CategoryCheckboxList({categories,selectedCategories}: Props) {
  return (
    <>
      {categories.map(category => (
        <CategoryCheckbox category={category} />
      ))}
    </>
  );
}
