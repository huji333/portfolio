class Admin::CategoriesController < Admin::Base
  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def edit
    @category = Category.find(params[:id])
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, notice: 'Category was successfully created.'
    else
      flash.now[:alert] = 'Category failed to create.'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: 'Category was successfully updated.'
    else
      flash.now[:alert] = 'Category failed to update.'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category = Category.find(params[:id])
    if @category.destroy
      redirect_to admin_categories_path, notice: 'Category was successfully destroyed.'
    else
      redirect_to admin_categories_path, alert: 'Category failed to destroy.'
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
