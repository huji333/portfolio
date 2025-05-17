class Admin::LensesController < Admin::Base
  def index
    @lenses = Lens.all
  end

  def new
    @lens = Lens.new
  end

  def edit
    @lens = Lens.find(params[:id])
  end

  def create
    @lens = Lens.new(lens_params)
    if @lens.save
      redirect_to admin_lenses_path, notice: 'Lens was successfully created.'
    else
      flash.now[:alert] = 'Lens failed to create.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @lens = Lens.find(params[:id])
    if @lens.destroy
      redirect_to admin_lenses_path, notice: 'Lens was successfully destroyed.'
    else
      redirect_to admin_lenses_path, alert: 'Lens failed to destroy.'
    end
  end

  private

  def lens_params
    params.require(:lens).permit(:name)
  end
end
