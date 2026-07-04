class Admin::LensesController < Admin::Base
  before_action :set_lens, only: %i[edit update destroy]

  def new
    @lens = Lens.new
  end

  def edit; end

  def create
    @lens = Lens.new(lens_params)

    if @lens.save
      redirect_to admin_gear_path, notice: 'Lens was successfully created.'
    else
      flash.now[:alert] = 'Lens failed to create.'
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @lens.update(lens_params)
      redirect_to admin_gear_path, notice: 'Lens was successfully updated.'
    else
      flash.now[:alert] = 'Lens failed to update.'
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @lens.destroy
      redirect_to admin_gear_path, notice: 'Lens was successfully destroyed.'
    else
      redirect_to admin_gear_path, alert: 'Lens could not be destroyed.'
    end
  end

  private

  def set_lens
    @lens = Lens.find(params[:id])
  end

  def lens_params
    params.expect(lens: [:name])
  end
end
