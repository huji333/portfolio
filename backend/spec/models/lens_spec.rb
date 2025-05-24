require 'rails_helper'

RSpec.describe Lens, type: :model do
  let(:lens) { build(:lens) }

  describe 'validations' do
    context 'name' do
      it 'should be valid with name' do
        lens.name = 'Test Lens'
        expect(lens).to be_valid
      end

      it 'should be invalid with blank name' do
        lens.name = ''
        expect(lens).to be_invalid
      end
    end
  end
end
