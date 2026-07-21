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

    context 'featured_rank' do
      it 'should be valid with featured_rank' do
        image.featured_rank = 1
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
    let!(:img1) { create(:image, title: 'A', taken_at: 4.days.ago, is_published: true) }
    let!(:img2) { create(:image, title: 'B', taken_at: 3.days.ago, is_published: true) }
    let!(:img3) { create(:image, title: 'C', taken_at: 2.days.ago, is_published: true) }
    let!(:img4) { create(:image, title: 'D', taken_at: 1.day.ago, is_published: true) }
    let!(:unpublished) { create(:image, title: 'Hidden', taken_at: 5.days.ago, is_published: false) }

    it 'returns only published images ordered by taken_at desc, id desc when none are featured' do
      result = Image.for_gallery(limit: 10)
      expect(result.map(&:title)).to eq(%w[D C B A])
    end

    it 'excludes unpublished images' do
      result = Image.for_gallery(limit: 10)
      expect(result.map(&:title)).not_to include('Hidden')
    end

    it 'fetches limit + 1 records to detect has_more' do
      result = Image.for_gallery(limit: 2)
      expect(result.size).to eq(3)
    end

    it 'returns timeline records after cursor position' do
      cursor = "t,#{(img3.taken_at.to_f * 1000).floor},#{img3.id}"
      result = Image.for_gallery(cursor: cursor, limit: 10)
      expect(result.map(&:title)).to eq(%w[B A])
    end

    it 'filters by category_ids' do
      cat = create(:category, name: 'Landscape')
      img1.categories << cat
      img3.categories << cat

      result = Image.for_gallery(category_ids: [cat.id], limit: 10)
      expect(result.map(&:title)).to eq(%w[C A])
    end

    it 'combines cursor and category filter' do
      cat = create(:category, name: 'Landscape')
      img1.categories << cat
      img3.categories << cat

      cursor = "t,#{(img3.taken_at.to_f * 1000).floor},#{img3.id}"
      result = Image.for_gallery(category_ids: [cat.id], cursor: cursor, limit: 10)
      expect(result.map(&:title)).to eq(%w[A])
    end

    context 'with featured images' do
      let!(:feat1) do
        create(:image, :featured, title: 'F1', featured_rank: 0, taken_at: 10.days.ago, is_published: true)
      end
      let!(:feat2) do
        create(:image, :featured, title: 'F2', featured_rank: 1, taken_at: 9.days.ago, is_published: true)
      end

      it 'pins featured images ahead of the timeline, ordered by featured_rank' do
        result = Image.for_gallery(limit: 10)
        expect(result.map(&:title)).to eq(%w[F1 F2 D C B A])
      end

      it 'does not duplicate featured images in the timeline segment' do
        result = Image.for_gallery(limit: 10)
        expect(result.map(&:title).count('F1')).to eq(1)
        expect(result.map(&:title).count('F2')).to eq(1)
      end

      it 'paginates across the featured -> timeline boundary and round-trips the cursor' do
        first = Image.for_gallery(limit: 2)
        expect(first.size).to eq(3) # limit + 1 fetched for has_more detection
        first_page = first.take(2)
        expect(first_page.map(&:title)).to eq(%w[F1 F2])

        last = first_page.last
        cursor = "f,#{last.featured_rank},#{last.id}"

        second = Image.for_gallery(cursor: cursor, limit: 2)
        expect(second.size).to eq(3) # B, A still remain after this page
        expect(second.take(2).map(&:title)).to eq(%w[D C])
      end

      it 'round-trips a cursor that lands mid-featured-segment' do
        cursor = "f,#{feat1.featured_rank},#{feat1.id}"
        result = Image.for_gallery(cursor: cursor, limit: 10)
        expect(result.map(&:title)).to eq(%w[F2 D C B A])
      end

      it 'transitions from an exhausted featured cursor straight into the timeline' do
        cursor = "f,#{feat2.featured_rank},#{feat2.id}"
        result = Image.for_gallery(cursor: cursor, limit: 10)
        expect(result.map(&:title)).to eq(%w[D C B A])
      end

      it 'combines featured pinning with category filtering' do
        cat = create(:category, name: 'Landscape')
        feat2.categories << cat
        img3.categories << cat

        result = Image.for_gallery(category_ids: [cat.id], limit: 10)
        expect(result.map(&:title)).to eq(%w[F2 C])
      end
    end
  end

  describe 'featured curation' do
    describe '#feature!' do
      it 'appends to the end of the featured list' do
        existing = create(:image, :featured, featured_rank: 0)
        image = create(:image)

        image.feature!

        expect(image.reload.featured_rank).to eq(1)
        expect(existing.reload.featured_rank).to eq(0)
      end

      it 'is a no-op when already featured' do
        image = create(:image, :featured, featured_rank: 0)
        other = create(:image, :featured, featured_rank: 1)

        image.feature!

        expect(image.reload.featured_rank).to eq(0)
        expect(other.reload.featured_rank).to eq(1)
      end
    end

    describe '#unfeature!' do
      it 'clears the rank and renormalizes the rest to 0..N-1' do
        a = create(:image, :featured, featured_rank: 0)
        b = create(:image, :featured, featured_rank: 1)
        c = create(:image, :featured, featured_rank: 2)

        b.unfeature!

        expect(b.reload.featured_rank).to be_nil
        expect(a.reload.featured_rank).to eq(0)
        expect(c.reload.featured_rank).to eq(1)
      end

      it 'is a no-op when not featured' do
        image = create(:image)

        expect { image.unfeature! }.not_to(change { image.reload.featured_rank })
      end
    end

    describe '.reorder_featured!' do
      it 'normalizes the given ids to 0..N-1 in the given order' do
        a = create(:image, :featured, featured_rank: 0)
        b = create(:image, :featured, featured_rank: 1)
        c = create(:image, :featured, featured_rank: 2)

        Image.reorder_featured!([c.id, a.id, b.id])

        expect(c.reload.featured_rank).to eq(0)
        expect(a.reload.featured_rank).to eq(1)
        expect(b.reload.featured_rank).to eq(2)
      end

      it 'leaves images not included untouched' do
        a = create(:image, :featured, featured_rank: 0)
        b = create(:image, :featured, featured_rank: 1)

        Image.reorder_featured!([a.id])

        expect(a.reload.featured_rank).to eq(0)
        expect(b.reload.featured_rank).to eq(1)
      end

      it 'fails loudly when an id is unknown' do
        a = create(:image, :featured, featured_rank: 0)

        expect { Image.reorder_featured!([a.id, 0]) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.bulk_assign!' do
    it 'offsets taken_at by 1 minute per image in id order when taken_at_base is given' do
      a = create(:image)
      b = create(:image)
      c = create(:image)
      base = Time.zone.parse('2024-01-01 10:00:00')

      Image.bulk_assign!([a.id, b.id, c.id], taken_at_base: base)

      ordered = [a, b, c].sort_by(&:id)
      ordered.each_with_index do |image, index|
        expect(image.reload.taken_at).to eq(base + index.minutes)
      end
    end

    it 'does not change taken_at when taken_at_base is nil' do
      image = create(:image, taken_at: 1.day.ago.change(usec: 0))
      original_taken_at = image.taken_at

      Image.bulk_assign!([image.id])

      expect(image.reload.taken_at).to eq(original_taken_at)
    end

    it 'overwrites an existing taken_at when taken_at_base is given' do
      image = create(:image, taken_at: 10.days.ago.change(usec: 0))
      base = Time.zone.parse('2024-01-01 10:00:00')

      Image.bulk_assign!([image.id], taken_at_base: base)

      expect(image.reload.taken_at).to eq(base)
    end
  end
end
