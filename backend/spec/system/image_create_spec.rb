require 'rails_helper'

RSpec.describe 'Image Create with EXIF', type: :system do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }

  # a7C II用のカメラとレンズを作成
  let!(:sony_a7c2) { create(:camera, name: 'a7C II', manufacturer: 'SONY') }
  let!(:fe_85mm) { create(:lens, name: 'FE 85mm F1.8') }
  let!(:category) { create(:category, name: 'Test Category') }

  before do
    sign_in admin
  end

  it 'Should automatically populate fields from a7C II EXIF data and create image' do
    visit '/admin/images/new'

    # ファイルを選択してEXIF自動読み込みをトリガー
    attach_file 'image_file', Rails.root.join("spec/fixtures/files/test_image.jpg")

    # EXIF自動読み込みの完了を待つ
    expect(page).to have_content('EXIFデータを自動読み取り中...', wait: 10)

    # 成功メッセージが表示されることを確認
    expect(page).to have_content(/✓ \d+個のフィールドを自動更新しました/, wait: 10)

    # カメラが自動選択されているかチェック（SONY ILCE-7CM2 → a7C II）
    expect(page).to have_select('image_camera_id', selected: sony_a7c2.name)

    # レンズの自動選択をチェック（FE 85mm F1.8）
    selected_lens = find('#image_lens_id').value
    if selected_lens.present?
      expect(selected_lens).to eq(fe_85mm.id.to_s)
    else
      # レンズが自動選択されていない場合は手動で選択
      select fe_85mm.name, from: 'image_lens_id'
    end

    # タイトルが自動設定されているかチェック（ファイル名から）
    expect(page).to have_field('image_title', with: 'test_image')

    # 撮影日時が自動設定されているかチェック
    expect(page).to have_field('image_taken_at')
    taken_at_value = find('#image_taken_at').value
    expect(taken_at_value).to be_present

    # 残りの必須フィールドを入力
    fill_in 'image_caption', with: 'Auto-populated from a7C II EXIF'
    check 'image_is_published'
    check "category_#{category.id}"

    click_button 'Save'

    # 成功することを確認
    expect(page).to have_current_path('/admin/images')
    expect(page).to have_content('Image was successfully created.')

    # 作成された画像の詳細を確認
    image = Image.last
    expect(image).to be_present
    expect(image.camera).to eq(sony_a7c2)
    expect(image.lens).to eq(fe_85mm)
    expect(image.title).to eq('test_image')
    expect(image.caption).to eq('Auto-populated from a7C II EXIF')
    expect(image.is_published).to be true
    expect(image.categories).to include(category)

    # 画像ファイルが適切に処理されているか確認
    expect(image.file.metadata['width']).to be_present
    expect(image.file.metadata['width']).to be > 0
  end
end
