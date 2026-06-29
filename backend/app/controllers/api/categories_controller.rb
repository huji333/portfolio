class Api::CategoriesController < ApplicationController
  def index
    categories = Category.order(:name)
    render json: categories.map { |c| c.as_json(only: %i[id name]) }
  end
end
