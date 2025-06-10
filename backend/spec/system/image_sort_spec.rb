require 'rails_helper'

RSpec.describe 'Image Sort', type: :system, js: true do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }
  let!(:image1) { create(:image, title: 'Image1') }
  let!(:image2) { create(:image, title: 'Image2') }
  let!(:image3) { create(:image, title: 'Image3') }

  before do
    sign_in admin
  end

  it 'Should sort images by row_order' do
    visit '/admin/images'

    # 行の存在確認
    expect(page).to have_selector('tr[data-image-id]', text: 'Image1')
    expect(page).to have_selector('tr[data-image-id]', text: 'Image2')
    expect(page).to have_selector('tr[data-image-id]', text: 'Image3')

    # ドラッグハンドルの存在確認
    expect(page).to have_selector('.handle')

    # Image3をImage1の位置にドラッグ&ドロップ
    source = find('tr[data-image-id]', text: 'Image3')
    target = find('tr[data-image-id]', text: 'Image1')
    handle = source.find('.handle')
    handle.drag_to(target)

    sleep 2

    within 'tbody[data-sortable-target="list"]' do
      expect(page).to have_selector('tr:nth-child(1)', text: 'Image3')
      expect(page).to have_selector('tr:nth-child(2)', text: 'Image1')
      expect(page).to have_selector('tr:nth-child(3)', text: 'Image2')
    end

    expect(Image.find_by(title: 'Image3').row_order).to be < Image.find_by(title: 'Image1').row_order
    expect(Image.find_by(title: 'Image1').row_order).to be < Image.find_by(title: 'Image2').row_order
  end
end
