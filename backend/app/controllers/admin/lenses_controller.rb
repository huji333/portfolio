class Admin::LensesController < Admin::Base
  before_action :set_lens, only: [:edit, :update, :destroy]

  def index
    @lenses = Lens.all
  end

  def new
    @lens = Lens.new
  end

  def edit; end

  def create
    @lens = Lens.new(lens_params)

    if @lens.save
      redirect_to admin_lenses_path, notice: 'Lens was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @lens.update(lens_params)
      redirect_to admin_lenses_path, notice: 'Lens was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lens.destroy
    redirect_to admin_lenses_path, notice: 'Lens was successfully destroyed.'
  end

  def lookup
    name = params[:name]&.strip

    if name.present?
      # 1. 完全一致（大文字小文字無視）
      lens = Lens.where("LOWER(name) = ?", name.downcase).first

      # 2. 部分一致（大文字小文字無視）
      lens ||= Lens.where("LOWER(name) LIKE ?", "%#{name.downcase}%").first

      # 3. 空白を正規化して部分一致
      unless lens
        cleaned_name = name.gsub(/\s+/, ' ').strip
        lens = Lens.where("LOWER(REPLACE(name, '  ', ' ')) LIKE ?", "%#{cleaned_name.downcase}%").first
      end

      if lens
        render json: { id: lens.id, name: lens.name }
      else
        render json: { error: 'Lens not found' }, status: :not_found
      end
    else
      render json: { error: 'Name parameter is required' }, status: :bad_request
    end
  end

  private

  def set_lens
    @lens = Lens.find(params[:id])
  end

  def lens_params
    params.require(:lens).permit(:name)
  end
end
