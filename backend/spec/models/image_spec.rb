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

    context 'display_order' do
      it 'should be valid with display_order' do
        image.display_order = 1
        expect(image).to be_valid
      end

      it 'should be invalid with nil display_order' do
        image.display_order = nil
        expect(image).to be_invalid
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
end
