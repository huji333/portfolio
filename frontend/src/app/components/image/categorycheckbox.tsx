import { CategoryType } from '@/utils/types';

type Props = {
  category:CategoryType
  onCheck: (categoryId: number) => void;
};

export default function CategoryCheckbox({ category, onCheck= f => f }: Props) {
  return(
    <label>
      <input
        type="checkbox"
        name={`${category.name}Checkbox`}
        onClick={() => onCheck(category.id)}
      />
      {category.name}
    </label>
  )
}
