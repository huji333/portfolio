class Api::CategoriesController < ApplicationController
  def index
    categories = Category.order(:id)
    render json: categories.map(&:as_json)
  end
end
