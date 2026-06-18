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

  describe '.resolve_from_exif' do
    it 'creates a new camera from raw make/model, defaulting display values' do
      expect do
        camera = Camera.resolve_from_exif(make: 'SONY', model: 'ILCE-7CM2')
        expect(camera.make).to eq('SONY')
        expect(camera.model).to eq('ILCE-7CM2')
        expect(camera.manufacturer).to eq('SONY')
        expect(camera.name).to eq('ILCE-7CM2')
      end.to change(Camera, :count).by(1)
    end

    it 'reuses an existing camera with the same make/model' do
      existing = Camera.create!(make: 'SONY', model: 'ILCE-7CM2', manufacturer: 'SONY', name: 'a7C II')

      expect do
        expect(Camera.resolve_from_exif(make: 'SONY', model: 'ILCE-7CM2')).to eq(existing)
      end.not_to change(Camera, :count)
    end

    it 'returns nil when make or model is blank' do
      expect(Camera.resolve_from_exif(make: 'SONY', model: nil)).to be_nil
      expect(Camera.resolve_from_exif(make: '', model: 'ILCE-7CM2')).to be_nil
    end
  end
end
