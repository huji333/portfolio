require "application_system_test_case"

class ImagesTest < ApplicationSystemTestCase
  setup do
    @image = images(:one)
  end

  test "visiting the index" do
    visit images_url
    assert_selector "h1", text: "Images"
  end

  test "should create image" do
    visit images_url
    click_on "New image"

    fill_in "Camera", with: @image.camera_id
    fill_in "Caption", with: @image.caption
    fill_in "Display order", with: @image.display_order
    check "Is published" if @image.is_published
    fill_in "Lens", with: @image.lens_id
    fill_in "Taken at", with: @image.taken_at
    fill_in "Title", with: @image.title
    click_on "Create Image"

    assert_text "Image was successfully created"
    click_on "Back"
  end

  test "should update Image" do
    visit image_url(@image)
    click_on "Edit this image", match: :first

    fill_in "Camera", with: @image.camera_id
    fill_in "Caption", with: @image.caption
    fill_in "Display order", with: @image.display_order
    check "Is published" if @image.is_published
    fill_in "Lens", with: @image.lens_id
    fill_in "Taken at", with: @image.taken_at.to_s
    fill_in "Title", with: @image.title
    click_on "Update Image"

    assert_text "Image was successfully updated"
    click_on "Back"
  end

  test "should destroy Image" do
    visit image_url(@image)
    click_on "Destroy this image", match: :first

    assert_text "Image was successfully destroyed"
  end
end
