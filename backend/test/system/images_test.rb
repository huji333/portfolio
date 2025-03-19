require "application_system_test_case"

class ImagesTest < ApplicationSystemTestCase
  setup do
    @image = images(:one)
    @camera = cameras(:one)
    @lens = lenses(:one)
  end

  test "visiting the index" do
    visit images_url
    assert_selector "h1", text: "画像一覧"
  end

  test "should create image" do
    visit images_url
    click_on "新規作成"

    select @camera.name, from: "image_camera_id"
    fill_in "image_caption", with: @image.caption
    fill_in "image_display_order", with: @image.display_order
    check "image_is_published" if @image.is_published
    select @lens.name, from: "image_lens_id"
    fill_in "image_taken_at", with: @image.taken_at
    fill_in "image_title", with: @image.title
    click_on "保存"

    assert_text "Image was successfully created"
    click_on "Back"
  end

  test "should update Image" do
    visit image_url(@image)
    click_on "編集", match: :first

    select @camera.name, from: "image_camera_id"
    fill_in "image_caption", with: @image.caption
    fill_in "image_display_order", with: @image.display_order
    check "image_is_published" if @image.is_published
    select @lens.name, from: "image_lens_id"
    fill_in "image_taken_at", with: @image.taken_at.to_s
    fill_in "image_title", with: @image.title
    click_on "保存"

    assert_text "Image was successfully updated"
    click_on "Back"
  end

  test "should destroy Image" do
    visit image_url(@image)
    accept_confirm do
      click_on "削除", match: :first
    end

    assert_text "Image was successfully destroyed"
  end
end
