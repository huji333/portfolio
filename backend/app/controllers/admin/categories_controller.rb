class Admin::CategoriesController < Admin::Base
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, notice: 'Category was successfully created.'
    else
      flash.now[:alert] = 'Category failed to create.'
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: 'Category was successfully updated.'
    else
      flash.now[:alert] = 'Category failed to update.'
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: 'Category was successfully destroyed.'
    else
      redirect_to admin_categories_path, alert: 'Category failed to destroy.'
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.expect(category: [:name])
  end
end
