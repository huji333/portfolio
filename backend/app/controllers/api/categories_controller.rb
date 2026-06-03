class Api::CategoriesController < ApplicationController
  def index
    categories = Category.order(:name)
    render json: categories.map(&:as_json)
  end
end
