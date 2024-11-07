require "test_helper"

class Admin::ImagesControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  setup do
    @admin = users(:one)
    @guest = users(:two)
  end

  test 'admin should get index' do
    login_as(@admin)
    get admin_images_path
    assert_response :success
  end

  test 'guest should not get index' do
    login_as(@guest)
    get admin_images_path
    response = JSON.parse(@response.body)
    assert_equal 'You are not authorized to perform this action.', response['error']
  end

  test 'logged out user should not get index' do
    get admin_images_path
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test 'admin should get show' do
    login_as(@admin)
    get admin_image_path(images(:one))
    assert_response :success
  end

  test 'admin should get new' do
    login_as(@admin)
    get new_admin_image_path
    assert_response :success
  end

  test 'admin should create image' do
    login_as(@admin)
    assert_difference('Image.count') do
      post admin_images_path, params: {
        image: {
          title: 'Sample Image',
          file: fixture_file_upload('test/fixtures/files/sample.jpg', 'image/jpeg'),
          caption: 'This is a sample caption',
          taken_at: Time.zone.now,
          camera_id: cameras(:one).id,
          lens_id: lenses(:one).id,
          display_order: 1,
          is_published: true
        }
      }
    end
    assert_equal 'Sample Image', Image.last.title
    assert_redirected_to admin_images_path
  end

  test 'admin should not create image with invalid params' do
    login_as(@admin)
    assert_no_difference('Image.count') do
      post admin_images_path, params: {
        image: {
          title: '',
          file: fixture_file_upload('test/fixtures/files/sample.jpg', 'image/jpeg'),
          caption: '',
          taken_at: Time.zone.now,
          camera_id: cameras(:one).id,
          lens_id: lenses(:one).id,
          display_order: 1,
          is_published: true
        }
      }
    end
    assert_redirected_to new_admin_image_path
  end

  test 'admin should get edit' do
    login_as(@admin)
    get edit_admin_image_path(images(:one))
    assert_response :success
  end

  test 'admin should update image' do
    login_as(@admin)
    patch admin_image_path(images(:one)), params: { image: { title: 'New Title' } }
    assert_redirected_to admin_image_path(images(:one))
    assert_equal 'New Title', images(:one).reload.title
  end

  test 'admin should not update image with invalid params' do
    login_as(@admin)
    patch admin_image_path(images(:one)), params: { image: { title: '' } }
    assert_response :success
  end

  test 'admin should destroy image' do
    login_as(@admin)
    assert_difference('Image.count', -1) do
      delete admin_image_path(images(:one))
    end
    assert_redirected_to admin_images_path
  end
end
