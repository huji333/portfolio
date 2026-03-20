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

    context 'title' do
      it 'should be valid with title' do
        image.title = 'Test Image'
        expect(image).to be_valid
      end

      it 'should be invalid with blank title' do
        image.title = ''
        expect(image).to be_invalid
      end
    end

    context 'caption' do
      it 'should be valid with caption' do
        image.caption = 'Test Caption'
        expect(image).to be_valid
      end

      it 'should be invalid with blank caption' do
        image.caption = ''
        expect(image).to be_invalid
      end
    end

    context 'taken_at' do
      it 'should be valid with past taken_at' do
        image.taken_at = 1.day.ago
        expect(image).to be_valid
      end

      it 'should be invalid with nil taken_at' do
        image.taken_at = nil
        expect(image).to be_invalid
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

      it 'should be invalid without camera' do
        image.camera = nil
        expect(image).to be_invalid
      end
    end

    context 'lens' do
      it 'should be valid with lens' do
        image.lens = build(:lens)
        expect(image).to be_valid
      end

      it 'should be invalid without lens' do
        image.lens = nil
        expect(image).to be_invalid
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
