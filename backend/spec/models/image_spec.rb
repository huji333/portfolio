require 'rails_helper'

RSpec.describe Image, type: :model do
  let(:image) { build(:image) }

  describe 'validations' do
    context 'file' do
      it 'should be valid with file' do
        image.file = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test_image.jpg"), 'image/jpeg')
        expect(image).to be_valid
      end

      it 'should be invalid with blank file' do
        image.file = nil
        expect(image).to be_invalid
      end
    end

    # title/taken_at are publish-quality requirements: required when published,
    # free to be blank while the record lives as a draft (bulk ingest).
    context 'title' do
      it 'should be valid with title' do
        image.title = 'Test Image'
        expect(image).to be_valid
      end

      it 'should be invalid with blank title when published' do
        image.is_published = true
        image.title = ''
        expect(image).to be_invalid
      end

      it 'should be valid with blank title when draft' do
        image.is_published = false
        image.title = ''
        expect(image).to be_valid
      end
    end

    context 'caption' do
      it 'should be valid with caption' do
        image.caption = 'Test Caption'
        expect(image).to be_valid
      end

      it 'should be valid with blank caption even when published' do
        image.is_published = true
        image.caption = ''
        expect(image).to be_valid
      end
    end

    context 'taken_at' do
      it 'should be valid with past taken_at' do
        image.taken_at = 1.day.ago
        expect(image).to be_valid
      end

      it 'should be invalid with nil taken_at when published' do
        image.is_published = true
        image.taken_at = nil
        expect(image).to be_invalid
      end

      it 'should be valid with nil taken_at when draft' do
        image.is_published = false
        image.taken_at = nil
        expect(image).to be_valid
      end

      it 'should be invalid with future taken_at' do
        image.taken_at = 1.day.from_now
        expect(image).to be_invalid
      end
    end

    context 'row_order' do
      it 'should be valid with row_order' do
        image.row_order = 1
        expect(image).to be_valid
      end
    end

    context 'is_published' do
      it 'should be valid with is_published' do
        image.is_published = true
        expect(image).to be_valid
      end

      it 'should be invalid with nil is_published' do
        image.is_published = nil
        expect(image).to be_invalid
      end
    end

    context 'camera' do
      it 'should be valid with camera' do
        image.camera = build(:camera)
        expect(image).to be_valid
      end

      # fail-open: a photo whose EXIF lacks a resolvable camera must still save.
      it 'should be valid without camera' do
        image.camera = nil
        expect(image).to be_valid
      end
    end

    context 'lens' do
      it 'should be valid with lens' do
        image.lens = build(:lens)
        expect(image).to be_valid
      end

      # fail-open: a photo without a LensModel (fixed/manual lens) must still save.
      it 'should be valid without lens' do
        image.lens = nil
        expect(image).to be_valid
      end
    end

    context 'categories' do
      it 'should be valid with categories' do
        image.save! # Save the image first
        category = create(:category)
        image.categories << category
        expect(image).to be_valid
      end
    end
  end

  # EXIF 補完はリクエスト内では走らず ProcessAttachedFileJob から呼ばれる
  # （エンキューの配線はジョブ側の spec で検証）。
  describe '#fill_exif_metadata!' do
    let(:exif_blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/test_image.jpg').open,
        filename: 'test_image.jpg', content_type: 'image/jpeg'
      )
    end

    it 'fills taken_at, camera and lens for a draft created without them' do
      image = Image.create!(file: exif_blob.signed_id, is_published: false)
      image.fill_exif_metadata!

      expect(image.taken_at).to eq(Time.utc(2024, 1, 1, 3, 56, 27))
      expect(image.camera).to have_attributes(make: 'SONY', model: 'ILCE-7CM2')
      expect(image.lens).to have_attributes(exif_name: 'FE 85mm F1.8')
    end

    it 'does not overwrite human-provided values' do
      camera = create(:camera)
      lens = create(:lens)
      taken_at = 2.days.ago.change(usec: 0)

      image = Image.create!(file: exif_blob.signed_id, is_published: false,
                            taken_at: taken_at, camera: camera, lens: lens)
      image.fill_exif_metadata!

      expect(image.taken_at).to eq(taken_at)
      expect(image.camera).to eq(camera)
      expect(image.lens).to eq(lens)
    end

    it 'keeps the draft intact when the file has no EXIF (fail-open)' do
      blank_blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(Vips::Image.black(4, 4).write_to_buffer('.jpg')),
        filename: 'blank.jpg', content_type: 'image/jpeg'
      )

      image = Image.create!(file: blank_blob.signed_id, is_published: false)
      image.fill_exif_metadata!

      expect(image).to be_persisted
      expect(image.taken_at).to be_nil
      expect(image.camera).to be_nil
      expect(image.lens).to be_nil
    end
  end

  describe '.uncurated' do
    it 'returns only drafts without a title' do
      untitled_draft = create(:image, :draft)
      titled_draft = create(:image, title: 'done', is_published: false)
      published = create(:image, is_published: true)

      expect(Image.uncurated).to include(untitled_draft)
      expect(Image.uncurated).not_to include(titled_draft, published)
    end
  end

  describe '#publishable?' do
    it 'is true when all publish requirements (title, taken_at) are present' do
      image = build(:image, is_published: false)

      expect(image.publishable?).to be(true)
    end

    it 'is false when title or taken_at is blank' do
      expect(build(:image, title: nil).publishable?).to be(false)
      expect(build(:image, taken_at: nil).publishable?).to be(false)
    end
  end

  describe '.for_gallery' do
    let!(:img1) { create(:image, title: 'A', row_order: 0, is_published: true) }
    let!(:img2) { create(:image, title: 'B', row_order: 1, is_published: true) }
    let!(:img3) { create(:image, title: 'C', row_order: 2, is_published: true) }
    let!(:img4) { create(:image, title: 'D', row_order: 3, is_published: true) }
    let!(:unpublished) { create(:image, title: 'Hidden', row_order: 4, is_published: false) }

    it 'returns only published images ordered by row_order, id' do
      result = Image.for_gallery(limit: 10)
      expect(result.map(&:title)).to eq(%w[A B C D])
    end

    it 'excludes unpublished images' do
      result = Image.for_gallery(limit: 10)
      expect(result.map(&:title)).not_to include('Hidden')
    end

    it 'fetches limit + 1 records to detect has_more' do
      result = Image.for_gallery(limit: 2)
      expect(result.size).to eq(3)
    end

    it 'returns records after cursor position' do
      cursor = "#{img2.row_order},#{img2.id}"
      result = Image.for_gallery(cursor: cursor, limit: 10)
      expect(result.map(&:title)).to eq(%w[C D])
    end

    it 'filters by category_ids' do
      cat = create(:category, name: 'Landscape')
      img1.categories << cat
      img3.categories << cat

      result = Image.for_gallery(category_ids: [cat.id], limit: 10)
      expect(result.map(&:title)).to eq(%w[A C])
    end

    it 'combines cursor and category filter' do
      cat = create(:category, name: 'Landscape')
      img1.categories << cat
      img3.categories << cat

      cursor = "#{img1.row_order},#{img1.id}"
      result = Image.for_gallery(category_ids: [cat.id], cursor: cursor, limit: 10)
      expect(result.map(&:title)).to eq(%w[C])
    end
  end
end
