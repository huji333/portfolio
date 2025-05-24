require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:category) { build(:category) }

  describe 'validations' do
    context 'name' do
      it 'should be valid with name' do
        category.name = 'Test Category'
        expect(category).to be_valid
      end

      it 'should be invalid with blank name' do
        category.name = ''
        expect(category).to be_invalid
      end
    end
  end
end
