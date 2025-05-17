class Api::CategoriesController < ApplicationController
  def index
    categories = Category.all
    render json: categories.map(&:as_json)
  end
end
