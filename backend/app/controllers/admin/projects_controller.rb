class Admin::ProjectsController < Admin::Base
  before_action :set_project, only: %i[edit update destroy]

  def index
    @projects = Project.order(created_at: :desc)
  end

  def new
    @project = Project.new
  end

  def edit; end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to admin_projects_path, notice: 'Project was successfully created.'
    else
      flash.now[:alert] = 'Project failed to create.'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to admin_projects_path, notice: 'Project was successfully updated.'
    else
      flash.now[:alert] = 'Project failed to update.'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @project.destroy
      redirect_to admin_projects_path, notice: 'Project was successfully destroyed.'
    else
      redirect_to admin_projects_path, alert: 'Project failed to destroy.'
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :link, :file)
  end
end
