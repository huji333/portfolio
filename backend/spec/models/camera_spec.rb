require 'rails_helper'

RSpec.describe Camera, type: :model do
  let(:camera) { build(:camera) }

  describe 'validations' do
    context 'name' do
      it 'should be valid with name' do
        camera.name = 'Test Camera'
        expect(camera).to be_valid
      end

      it 'should be invalid with blank name' do
        camera.name = ''
        expect(camera).to be_invalid
      end
    end

    context 'manufacturer' do
      it 'should be valid with manufacturer' do
        camera.manufacturer = 'Test Manufacturer'
        expect(camera).to be_valid
      end

      it 'should be invalid with blank manufacturer' do
        camera.manufacturer = ''
        expect(camera).to be_invalid
      end
    end
  end
end
