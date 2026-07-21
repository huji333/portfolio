require 'rails_helper'

RSpec.describe 'Admin::Images', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :admin) }

  # NOTE: id を固定して create すると PG のシーケンスが進まず、
  # 以降の自動採番 create が duplicate key で落ちるため自動採番に任せる。
  # id 順が編集カードの ←/→ 遷移順にもなるため、作成順がそのままテストの前提になる。
  let!(:image1) { create(:image, title: 'Test Image 1') }
  let!(:image2) { create(:image, title: 'Test Image 2') }
  let!(:image3) { create(:image, title: 'Test Image 3') }
  let!(:image4) { create(:image, title: 'Test Image 4') }

  before { sign_in user }

  describe 'GET /admin/images' do
    it 'renders and surfaces the uncurated draft count with a filter link' do
      create(:image, :draft)

      get '/admin/images'

      expect(response).to have_http_status(:success)
      expect(response.body).to include('未編集の下書き 1 枚を表示')
    end

    it 'renders the bulk edit form with per-row checkboxes' do
      get '/admin/images'

      expect(response.body).to include('bulk_update')
      expect(response.body).to include("select_image_#{image1.id}")
      expect(response.body).to include('選択した画像に適用')
    end

    it 'filters to uncurated drafts only' do
      draft = create(:image, :draft)

      get '/admin/images', params: { filter: 'uncurated' }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("data-image-id='#{draft.id}'").or include("data-image-id=\"#{draft.id}\"")
    end

    it 'paginates the list and preserves the filter in page links' do
      stub_const('Admin::ImagesController::PER_PAGE', 2)

      get '/admin/images', params: { page: 2 }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("select_image_#{image3.id}")
      expect(response.body).not_to include("select_image_#{image1.id}")
      expect(response.body).to include('pagination')
    end

    it 'rounds an out-of-range page down to the last page instead of erroring' do
      stub_const('Admin::ImagesController::PER_PAGE', 2)

      get '/admin/images', params: { page: 99 }

      expect(response).to have_http_status(:success)
      expect(response.body).to include("select_image_#{image4.id}")
    end
  end

  describe 'GET /admin/images/arrange' do
    it 'lists only featured images for reordering' do
      featured = create(:image, :featured, featured_rank: 0)
      draft = create(:image, :draft)

      get '/admin/images/arrange'

      expect(response).to have_http_status(:success)
      expect(response.body)
        .to include("data-image-id='#{featured.id}'").or include("data-image-id=\"#{featured.id}\"")
      # 下書き・非 featured の公開画像は並び替え画面に出さない（featured のみの鏡）
      [draft, image1].each do |image|
        expect(response.body).not_to include("data-image-id='#{image.id}'")
        expect(response.body).not_to include("data-image-id=\"#{image.id}\"")
      end
    end
  end

  describe 'GET /admin/images publish status column' do
    it 'shows status badges without inline publish/unpublish buttons' do
      create(:image, :draft, title: 'Curated Draft', taken_at: 1.day.ago)
      uncurated = create(:image, :draft, taken_at: nil)

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

    it 'features the new image when the featured checkbox is checked' do
      post '/admin/images',
           params: { image: { title: 'New Featured', file: file, is_featured: '1' } }

      expect(Image.order(:id).last.featured_rank).to eq(0)
    end
  end

  describe 'PATCH /admin/images/:id (publish via submit buttons)' do
    let!(:draft) { create(:image, :draft) }

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

  describe 'PATCH /admin/images/:id (featured toggle)' do
    it 'features the image when the checkbox is checked' do
      patch "/admin/images/#{image1.id}", params: { image: { title: image1.title, is_featured: '1' } }

      expect(image1.reload.featured_rank).to eq(0)
    end

    it 'unfeatures the image and renormalizes the rest when unchecked' do
      image1.feature!
      image2.feature!

      patch "/admin/images/#{image1.id}", params: { image: { title: image1.title, is_featured: '0' } }

      expect(image1.reload.featured_rank).to be_nil
      expect(image2.reload.featured_rank).to eq(0)
    end

    it 'leaves the featured state untouched when the field is not submitted' do
      image1.feature!

      patch "/admin/images/#{image1.id}", params: { image: { title: 'Renamed only' } }

      expect(image1.reload.featured_rank).to eq(0)
    end
  end

  describe 'PATCH /admin/images/:id (card navigation)' do
    it 'saves and moves to the next image in id order with 次へ' do
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
    let!(:f1) { create(:image, :featured, title: 'F1', featured_rank: 0) }
    let!(:f2) { create(:image, :featured, title: 'F2', featured_rank: 1) }
    let!(:f3) { create(:image, :featured, title: 'F3', featured_rank: 2) }

    it 'moves the image to the given position within the featured list' do
      post "/admin/images/#{f1.id}/insert_at", params: { position: 2 }
      expect(response).to have_http_status(:success)

      expect(Image.featured.pluck(:id)).to eq([f2.id, f3.id, f1.id])
    end

    it 'moves the image to the front of the featured list' do
      post "/admin/images/#{f3.id}/insert_at", params: { position: 0 }
      expect(response).to have_http_status(:success)

      expect(Image.featured.pluck(:id)).to eq([f3.id, f1.id, f2.id])
    end

    it 'does not touch images outside the featured set' do
      post "/admin/images/#{f1.id}/insert_at", params: { position: 1 }
      expect(response).to have_http_status(:success)

      expect(image1.reload.featured_rank).to be_nil
      expect(image2.reload.featured_rank).to be_nil
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
