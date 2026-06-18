require 'rails_helper'

RSpec.describe ExifExtractor do
  let(:fixture_path) { Rails.root.join('spec/fixtures/files/test_image.jpg') }

  describe '#call with a real EXIF JPEG (SONY a7C II)' do
    subject(:result) { described_class.new(fixture_path.binread).call }

    it 'extracts make and model' do
      expect(result.make).to eq('SONY')
      expect(result.model).to eq('ILCE-7CM2')
    end

    it 'extracts the lens model' do
      expect(result.lens_model).to eq('FE 85mm F1.8')
    end

    it 'extracts taken_at as the correct absolute instant (12:56:27 +09:00)' do
      expect(result.taken_at).to eq(Time.utc(2024, 1, 1, 3, 56, 27))
    end
  end

  describe '#call with an image that has no EXIF' do
    subject(:result) { described_class.new(Vips::Image.black(4, 4).write_to_buffer('.jpg')).call }

    it 'returns an all-nil result' do
      expect(result).to eq(ExifExtractor::EMPTY)
    end
  end

  describe '.from_blob' do
    it 'fails open with EMPTY when the blob is not a decodable image' do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new('not an image'), filename: 'x.txt', content_type: 'text/plain'
      )

      expect(described_class.from_blob(blob)).to eq(ExifExtractor::EMPTY)
    end
  end
end
