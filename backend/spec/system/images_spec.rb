require 'rails_helper'

RSpec.describe "Images", type: :system do
  let(:admin) { create(:user, :admin) }
  let(:image) { create(:image) }
  let(:camera) { create(:camera) }
  let(:lens) { create(:lens) }

  before do
    sign_in admin
    # Ensure camera and lens exist
    camera
    lens
  end

  describe "visiting the index" do
    it "shows the images page" do
      visit admin_images_path
      expect(page).to have_selector("h1", text: "画像一覧")
    end
  end

  describe "creating a new image" do
    before do
      visit new_admin_image_path
    end

    it "creates a new image with valid attributes" do
      fill_in "image_title", with: "Test Image"
      fill_in "image_caption", with: "Test caption"
      fill_in "image_taken_at", with: Time.current.strftime("%Y-%m-%dT%H:%M:%S")
      select camera.name, from: "image_camera_id"
      select lens.name, from: "image_lens_id"
      fill_in "image_display_order", with: 1
      check "image_is_published" if image.is_published
      click_on "保存"

      expect(page).to have_selector(".alert.alert-info", text: "Image was successfully created.")
    end
  end

  describe "updating an image" do
    before do
      image # ensure image exists
      visit edit_admin_image_path(image)
    end

    it "updates the image with valid attributes" do
      fill_in "image_title", with: "Updated Image"
      fill_in "image_caption", with: "Updated caption"
      fill_in "image_taken_at", with: Time.current.strftime("%Y-%m-%dT%H:%M:%S")
      select camera.name, from: "image_camera_id"
      select lens.name, from: "image_lens_id"
      fill_in "image_display_order", with: 2
      check "image_is_published" if image.is_published
      click_on "保存"

      # After successful update, we should be on the show page
      expect(page).to have_selector("h1", text: "image")
      expect(page).to have_text("Updated Image")
      expect(page).to have_text("Updated caption")
    end
  end

  describe "destroying an image" do
    before do
      image # ensure image exists
      visit admin_images_path
    end

    it "destroys the image" do
      expect {
        accept_confirm "本当に削除しますか？" do
          click_button "削除", match: :first
        end
      }.to change(Image, :count).by(-1)

      expect(page).to have_selector(".alert.alert-info", text: "Image was successfully destroyed.")
    end
  end
end
