class Api::ImagesController < ApplicationController
  def index
    @images = Image.all
    render json: @images
  end
  def show
    @image = Image.find(params[:id])
    render json: {
      image: @image,
      file: @image.file.url
    }
  end
end
