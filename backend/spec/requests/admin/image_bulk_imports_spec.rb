require 'rails_helper'

RSpec.describe 'Admin::ImageBulkImports', type: :request do
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  let(:user) { create(:user, :admin) }

  before { sign_in user }

  def upload_fixture_blob
    ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join('spec/fixtures/files/test_image.jpg').open,
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
  end

  describe 'GET /admin/image_bulk_import/new' do
    it 'renders the bulk import form' do
      get '/admin/image_bulk_import/new'

      expect(response).to have_http_status(:success)
      expect(response.body).to include('画像の一括取り込み')
    end
  end

  describe 'POST /admin/image_bulk_import' do
    it 'creates a draft per file with shared categories; EXIF fills after the job runs' do
      category = create(:category)
      signed_ids = [upload_fixture_blob.signed_id, upload_fixture_blob.signed_id]

      expect do
        post '/admin/image_bulk_import',
             params: { bulk: { files: signed_ids, category_ids: [category.id] } }
      end.to change(Image, :count).by(2)

      expect(response).to redirect_to(admin_images_path(filter: 'uncurated'))

      # リクエスト内では S3 ダウンロードを伴う処理をしない（EXIF はジョブで補完）
      drafts = Image.order(:id).last(2)
      drafts.each do |draft|
        expect(draft.is_published).to be(false)
        expect(draft.title).to be_nil
        expect(draft.taken_at).to be_nil
        expect(draft.categories).to eq([category])
      end

      perform_enqueued_jobs

      drafts.each(&:reload)
      drafts.each do |draft|
        expect(draft.taken_at).to eq(Time.utc(2024, 1, 1, 3, 56, 27))
        expect(draft.camera).to have_attributes(make: 'SONY', model: 'ILCE-7CM2')
      end
    end

    it 'applies an explicitly chosen shared camera/lens over EXIF' do
      camera = create(:camera)
      lens = create(:lens)

      post '/admin/image_bulk_import',
           params: { bulk: { files: [upload_fixture_blob.signed_id],
                             camera_id: camera.id, lens_id: lens.id } }

      expect(response).to redirect_to(admin_images_path(filter: 'uncurated'))
      perform_enqueued_jobs

      draft = Image.order(:id).last
      # EXIF（SONY ILCE-7CM2）ではなく手動選択が勝つ。taken_at は EXIF から入る
      expect(draft.camera).to eq(camera)
      expect(draft.lens).to eq(lens)
      expect(draft.taken_at).to eq(Time.utc(2024, 1, 1, 3, 56, 27))
    end

    it 'isolates failures per file: valid files are ingested, invalid ones reported' do
      signed_ids = [upload_fixture_blob.signed_id, 'bogus-signed-id']

      expect do
        post '/admin/image_bulk_import', params: { bulk: { files: signed_ids } }
      end.to change(Image, :count).by(1)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('1枚の取り込みに失敗しました')
    end

    it 'rejects a submission without files' do
      expect do
        post '/admin/image_bulk_import', params: { bulk: { files: [] } }
      end.not_to change(Image, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
