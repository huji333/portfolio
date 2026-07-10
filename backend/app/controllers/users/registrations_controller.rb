class Users::RegistrationsController < Devise::RegistrationsController
  before_action :block_new_registration, only: %i[new create]

  private

  def block_new_registration
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end
end
