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
end
