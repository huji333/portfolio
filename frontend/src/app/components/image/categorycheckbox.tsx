import { CategoryType } from '@/utils/types';

type Props = {
  category:CategoryType
};

export default function CategoryCheckbox({ category }: Props) {
  return(
    <label>
      <input type="checkbox" name={`${category.name}Checkbox`}  />
      {category.name}
    </label>
  )
}
