class ProjectsController < ApplicationController
  def index
    if manager?
      @projects = Project.where(manager_id: current_user.id)
    else
      @projects = current_user.projects
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.manager = current_user

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path, notice: 'Project was successfully deleted.'
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, :avatar)
  end
end
