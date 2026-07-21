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

  # マジックバイト検査を通らない非画像ファイルを、宣言 content_type だけ image/jpeg と偽って送る
  def upload_spoofed_non_image_blob
    ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join('spec/fixtures/files/not_an_image.txt').open,
      filename: 'not_an_image.txt',
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
    it 'creates a draft with shared categories; EXIF fills after the job runs' do
      category = create(:category)

      expect do
        post '/admin/image_bulk_import',
             params: { bulk: { files: [upload_fixture_blob.signed_id], category_ids: [category.id] } }
      end.to change(Image, :count).by(1)

      expect(response).to redirect_to(admin_images_path(filter: 'uncurated'))

      # リクエスト内では S3 ダウンロードを伴う処理をしない（EXIF はジョブで補完）
      draft = Image.order(:id).last
      expect(draft.is_published).to be(false)
      expect(draft.title).to be_nil
      expect(draft.taken_at).to be_nil
      expect(draft.categories).to eq([category])

      perform_enqueued_jobs

      draft.reload
      expect(draft.taken_at).to eq(Time.utc(2024, 1, 1, 3, 56, 27))
      expect(draft.camera).to have_attributes(make: 'SONY', model: 'ILCE-7CM2')
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

    describe 'checksum ベースの重複検出' do
      it 'collapses a duplicate file within the same batch and purges the extra blob' do
        blob1 = upload_fixture_blob
        blob2 = upload_fixture_blob

        expect do
          post '/admin/image_bulk_import', params: { bulk: { files: [blob1.signed_id, blob2.signed_id] } }
        end.to change(Image, :count).by(1)

        expect(response).to have_http_status(:ok)
        created_image = Image.order(:id).last
        expect(response.body).to include("既存の画像（ID: #{created_image.id}）と重複")

        perform_enqueued_jobs

        # blob1 は Image に添付されて残り、blob2（重複と判定された方）だけ purge される
        expect(ActiveStorage::Blob.exists?(blob1.id)).to be(true)
        expect(ActiveStorage::Blob.exists?(blob2.id)).to be(false)
      end

      it 'detects a duplicate against a blob already attached from an earlier import and purges the new blob' do
        post '/admin/image_bulk_import', params: { bulk: { files: [upload_fixture_blob.signed_id] } }
        existing_image = Image.order(:id).last

        second_blob = upload_fixture_blob

        expect do
          post '/admin/image_bulk_import', params: { bulk: { files: [second_blob.signed_id] } }
        end.not_to change(Image, :count)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("既存の画像（ID: #{existing_image.id}）と重複")

        perform_enqueued_jobs
        expect(ActiveStorage::Blob.exists?(second_blob.id)).to be(false)
      end
    end

    describe 'サーバサイドのファイル検証' do
      it 'rejects a non-image file whose content type is spoofed as image/jpeg, purging the blob' do
        blob = upload_spoofed_non_image_blob

        expect do
          post '/admin/image_bulk_import', params: { bulk: { files: [blob.signed_id] } }
        end.not_to change(Image, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('画像ではありません')

        perform_enqueued_jobs
        expect(ActiveStorage::Blob.exists?(blob.id)).to be(false)
      end

      it 'rejects a file over the 50MB limit, purging the blob' do
        blob = upload_fixture_blob
        allow_any_instance_of(ActiveStorage::Blob)
          .to receive(:byte_size).and_return(Admin::ImageBulkImportsController::MAX_FILE_SIZE + 1)

        expect do
          post '/admin/image_bulk_import', params: { bulk: { files: [blob.signed_id] } }
        end.not_to change(Image, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('サイズ上限50MBを超えています')

        perform_enqueued_jobs
        expect(ActiveStorage::Blob.exists?(blob.id)).to be(false)
      end

      it 'still ingests a valid image under the limit with the correct content type' do
        expect do
          post '/admin/image_bulk_import', params: { bulk: { files: [upload_fixture_blob.signed_id] } }
        end.to change(Image, :count).by(1)

        expect(response).to redirect_to(admin_images_path(filter: 'uncurated'))
      end
    end

    describe 'save 失敗時の孤立 blob 後始末' do
      it 'purges the newly uploaded blob when image.save fails' do
        allow_any_instance_of(Image).to receive(:save).and_return(false)
        blob = upload_fixture_blob

        expect do
          post '/admin/image_bulk_import', params: { bulk: { files: [blob.signed_id] } }
        end.not_to change(Image, :count)

        expect(response).to have_http_status(:unprocessable_content)

        perform_enqueued_jobs
        expect(ActiveStorage::Blob.exists?(blob.id)).to be(false)
      end
    end
  end
end
