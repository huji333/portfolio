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

  describe '.resolve_from_exif' do
    it 'creates a new lens from the raw exif name, defaulting the display name' do
      expect do
        lens = Lens.resolve_from_exif('FE 85mm F1.8')
        expect(lens.exif_name).to eq('FE 85mm F1.8')
        expect(lens.name).to eq('FE 85mm F1.8')
      end.to change(Lens, :count).by(1)
    end

    it 'reuses an existing lens with the same exif name' do
      existing = Lens.create!(exif_name: 'FE 85mm F1.8', name: 'Sony 85')

      expect do
        expect(Lens.resolve_from_exif('FE 85mm F1.8')).to eq(existing)
      end.not_to change(Lens, :count)
    end

    it 'returns nil when the exif name is blank (fail-open for missing LensModel)' do
      expect(Lens.resolve_from_exif(nil)).to be_nil
      expect(Lens.resolve_from_exif('')).to be_nil
    end
  end

  describe '#uncurated?' do
    it 'is uncurated when the display name still equals the raw exif name' do
      expect(Lens.new(exif_name: 'XF35mmF1.4 R', name: 'XF35mmF1.4 R')).to be_uncurated
    end

    it 'is curated once the display name has been edited' do
      expect(Lens.new(exif_name: 'XF35mmF1.4 R', name: 'Fujifilm XF 35mm F1.4')).not_to be_uncurated
    end

    it 'treats manually-created lenses (blank exif_name) as curated' do
      expect(Lens.new(exif_name: nil, name: 'Built-in lens')).not_to be_uncurated
    end
  end
end
