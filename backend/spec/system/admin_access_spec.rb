require 'rails_helper'

RSpec.describe 'Admin Access', type: :system do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }
  let(:guest) { create(:user, :guest) }

  it 'Not logged in user should be redirected to sign in page' do
    visit '/admin'
    expect(page).to have_current_path('/users/sign_in')
  end

  it 'Guest user should not access /admin' do
    sign_in guest
    visit '/admin'
    expect(page).to have_content('You are not authorized to perform this action.')
  end

  it 'Admin user should access /admin' do
    sign_in admin
    visit '/admin'
    expect(page).to have_current_path('/admin')
    expect(page).to have_content('管理者ページ')
  end
end
