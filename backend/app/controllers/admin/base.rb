class Admin::Base < ApplicationController
  include Admin::Authorization

  rescue_from ActiveRecord::RecordNotFound do
    render404
  end

  private

  def render404
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end
end
