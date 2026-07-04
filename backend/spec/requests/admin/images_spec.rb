require 'rails_helper'

RSpec.describe 'Admin::Images', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }

  # NOTE: id を固定して create すると PG のシーケンスが進まず、
  # 以降の自動採番 create が duplicate key で落ちるため自動採番に任せる。
  let!(:image1) { create(:image, title: 'Test Image 1', row_order: 100) }
  let!(:image2) { create(:image, title: 'Test Image 2', row_order: 200) }
  let!(:image3) { create(:image, title: 'Test Image 3', row_order: 300) }
  let!(:image4) { create(:image, title: 'Test Image 4', row_order: 400) }

  before { sign_in user }

  describe 'GET /admin/images' do
    it 'renders and surfaces the uncurated draft count with a filter link' do
      create(:image, :draft, row_order: 500)

      get '/admin/images'

      expect(response).to have_http_status(:success)
      expect(response.body).to include('未編集の下書き 1 枚を表示')
    end

    it 'filters to uncurated drafts only' do
      draft = create(:image, :draft, row_order: 500)

      get '/admin/images', params: { filter: 'uncurated' }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("data-image-id='#{draft.id}'").or include("data-image-id=\"#{draft.id}\"")
    end
  end

  describe 'GET /admin/images/arrange' do
    it 'lists only published images for reordering' do
      draft = create(:image, :draft, row_order: 500)

      get '/admin/images/arrange'

      expect(response).to have_http_status(:success)
      expect(response.body).to include("data-image-id='#{image1.id}'").or include("data-image-id=\"#{image1.id}\"")
      # 下書きは並び替え画面に出さない（公開ギャラリーの鏡）
      expect(response.body).not_to include("data-image-id='#{draft.id}'")
      expect(response.body).not_to include("data-image-id=\"#{draft.id}\"")
    end
  end

  describe 'GET /admin/images publish status column' do
    it 'shows status badges without inline publish/unpublish buttons' do
      create(:image, :draft, title: 'Curated Draft', taken_at: 1.day.ago, row_order: 500)
      uncurated = create(:image, :draft, taken_at: nil, row_order: 600)

      get '/admin/images'

      expect(response.body).to include('公開中')
      expect(response.body).to include('下書き')
      expect(response.body).to include('未編集')
      # インラインの公開/非公開ボタンは廃止（公開切替は編集画面へ集約）
      expect(response.body).not_to include('非公開にする')
      expect(response.body).not_to include('公開する')
      expect(uncurated.reload.publishable?).to be(false)
    end
  end

  describe 'POST /admin/images (publish via submit buttons)' do
    let(:file) { fixture_file_upload('test_image.jpg', 'image/jpeg') }

    it 'creates a draft with plain 保存' do
      post '/admin/images', params: { image: { title: 'New Draft', file: file } }

      expect(Image.order(:id).last).to have_attributes(title: 'New Draft', is_published: false)
    end

    it 'creates a published image with 公開する' do
      post '/admin/images',
           params: { commit_publish: '公開する',
                     image: { title: 'New Published', taken_at: 1.day.ago, file: file } }

      expect(Image.order(:id).last).to have_attributes(title: 'New Published', is_published: true)
    end
  end

  describe 'PATCH /admin/images/:id (publish via submit buttons)' do
    let!(:draft) { create(:image, :draft, row_order: 500) }

    it 'publishes with 公開する and stays on the card' do
      patch "/admin/images/#{draft.id}",
            params: { commit_publish: '公開する', image: { title: 'Curated', taken_at: '2026-01-01T10:00' } }

      expect(draft.reload.is_published).to be(true)
      expect(response).to redirect_to(edit_admin_image_path(draft))
      expect(flash[:notice]).to include('公開しました')
    end

    it 're-renders as draft when publish requirements are missing' do
      patch "/admin/images/#{draft.id}", params: { commit_publish: '公開する', image: { title: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(draft.reload.is_published).to be(false)
      # 再描画されたフォームは下書き状態のボタン（公開する）を出す
      expect(response.body).to include('公開する')
    end

    it 'unpublishes a published image with 非公開に戻す' do
      patch "/admin/images/#{image1.id}", params: { commit_draft: '非公開に戻す', image: { title: image1.title } }

      expect(image1.reload.is_published).to be(false)
      expect(response).to redirect_to(edit_admin_image_path(image1))
    end
  end

  describe 'PATCH /admin/images/:id (card navigation)' do
    it 'saves and moves to the next image in display order with 次へ' do
      patch "/admin/images/#{image2.id}", params: { nav_next: '次へ →', image: { title: 'Renamed' } }

      expect(image2.reload.title).to eq('Renamed')
      expect(response).to redirect_to(edit_admin_image_path(image3))
    end

    it 'saves and moves to the previous image with 前へ' do
      patch "/admin/images/#{image2.id}", params: { nav_prev: '← 前へ', image: { title: 'Renamed' } }

      expect(response).to redirect_to(edit_admin_image_path(image1))
    end

    it 'stays on the current card after a plain 保存' do
      patch "/admin/images/#{image2.id}", params: { image: { title: 'Renamed' } }

      expect(response).to redirect_to(edit_admin_image_path(image2))
      expect(flash[:notice]).to include('保存しました')
    end

    it 'disables 前へ on the first card and 次へ on the last card' do
      get "/admin/images/#{image1.id}/edit"
      expect(response.body).to match(/nav_prev[^>]*disabled/)

      get "/admin/images/#{image4.id}/edit"
      expect(response.body).to match(/nav_next[^>]*disabled/)
    end
  end

  describe 'POST /admin/images/:id/insert_at' do
    it 'should insert the image at the given position' do
      expect(Image.rank(:row_order).pluck(:id)).to eq([image1.id, image2.id, image3.id, image4.id])

      post "/admin/images/#{image1.id}/insert_at", params: { position: 2 }
      expect(response).to have_http_status(:success)

      expect(Image.rank(:row_order).pluck(:id)).to eq([image2.id, image3.id, image1.id, image4.id])
    end

    it 'translates a published-list index into a global position, stepping over an interleaved draft' do
      # global順: image1(100) < draft(150) < image2(200) < image3(300) < image4(400)
      draft = create(:image, :draft, taken_at: nil, row_order: 150)

      # 公開リスト [image1, image2, image3, image4] の index 1 へ image4 を移動
      post "/admin/images/#{image4.id}/insert_at", params: { position: 1 }
      expect(response).to have_http_status(:success)

      # draft は image1 の直後に留まり、image4 は image2 の直前へ入る
      expect(Image.rank(:row_order).pluck(:id))
        .to eq([image1.id, draft.id, image4.id, image2.id, image3.id])
    end

    it 'drops to the tail of the published list without overtaking a trailing draft' do
      # 末尾の公開画像より後ろに滞留する下書き
      draft = create(:image, :draft, taken_at: nil, row_order: 500)

      # 公開リスト末尾（index 3）へ image1 を移動
      post "/admin/images/#{image1.id}/insert_at", params: { position: 3 }
      expect(response).to have_http_status(:success)

      # image1 は最後の公開画像 image4 の直後、末尾の draft の前に入る
      expect(Image.rank(:row_order).pluck(:id))
        .to eq([image2.id, image3.id, image4.id, image1.id, draft.id])
    end
  end

  describe 'POST /admin/images/extract_exif' do
    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/test_image.jpg').open,
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
    end

    it 'resolves and auto-creates camera/lens and returns taken_at' do
      expect do
        post '/admin/images/extract_exif', params: { signed_id: blob.signed_id }
      end.to change(Camera, :count).by(1).and change(Lens, :count).by(1)

      expect(response).to have_http_status(:success)
      body = response.parsed_body
      expect(body.dig('camera', 'label')).to eq('SONY ILCE-7CM2')
      expect(body.dig('lens', 'label')).to eq('FE 85mm F1.8')
      expect(body['taken_at']).to eq('2024-01-01T03:56')
    end

    it 'fails open with nulls for an invalid signed id' do
      post '/admin/images/extract_exif', params: { signed_id: 'bogus' }

      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to eq('taken_at' => nil, 'camera' => nil, 'lens' => nil)
    end
  end

  describe 'GET /admin/images/:id/edit' do
    it 'shows the image preview and card position on the edit card' do
      get "/admin/images/#{image2.id}/edit"

      expect(response).to have_http_status(:success)
      # プレビュー画像（Active Storage の representation URL）が描画される
      expect(response.body).to include('/rails/active_storage/representations/')
      expect(response.body).to include('2 / 4 枚目')
    end
  end
end
