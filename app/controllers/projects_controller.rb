class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]

  def index
    if manager?
      @projects = Project.where(manager_id: current_user.id)
    else
      @projects = current_user.projects
    end
  end

  def show
    @users = User.order(:name)
  end

  def new
    @project = Project.new
    @users = User.order(:name)
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
    @users = User.order(:name)
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      @users = User.order(:name)
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: 'Project was successfully deleted.'
  end

  def assign_users
    @project = Project.find(params[:id])
  end
  

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :avatar, user_ids: [])
  end
end
