class Users::RegistrationsController < Devise::RegistrationsController
  def new
    render_not_found
  end

  def create
    render_not_found
  end

  private

  def render_not_found
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end
end
