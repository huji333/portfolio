require 'rails_helper'

RSpec.describe ExifExtractor do
  describe '.from_blob' do
    it 'fails open with EMPTY when the blob is not a decodable image' do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new('not an image'), filename: 'x.txt', content_type: 'text/plain'
      )

      expect(described_class.from_blob(blob)).to eq(ExifExtractor::EMPTY)
    end
  end
end
