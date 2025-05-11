class Api::CategoriesController < ApplicationController
  def index
    categories = Category.all
    render json: categories.map { |category| category.as_json }
  end
end
