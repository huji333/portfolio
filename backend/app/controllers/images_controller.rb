class ImagesController < ApplicationController
  before_action :set_image, only: %i[ show edit update destroy ]

  def index
    @images = Image.all
  end

  def show; end

  def new
    @image = Image.new
  end

  def edit; end

  def create
    @image = Image.new(image_params)

    if @image.save
      redirect_to images_path, notice: "Imageが作成されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @image.update(image_params)
      redirect_to images_path, notice: "Imageが更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @image.destroy!
    redirect_to images_path, notice: "Imageが削除されました。"
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:title, :caption, :taken_at, :camera_id, :lens_id, :display_order, :is_published)
  end
end
