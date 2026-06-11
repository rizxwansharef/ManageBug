class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show update destroy edit ]
  before_action :blocked_routes, only: %i[new ]

  def index
    if manager?
      @projects = Project.where(manager_id: current_user.id)
    else
      @projects = current_user.projects
    end
  end

  def show
    authorize! :read, @project
    @selected_project = @project
  end


  def new
  end

  def create
    @project = Project.new(project_params)
    @project.manager = current_user

    if @project.save
        @project.users.each do |user|
            skip if user == current_user
          Notification.create(
            recipient_id: user.id,
            message: "You have been added to the project '#{@project.name}' by #{current_user.name}.",
          )
        end
          redirect_to projects_path, notice: "Project was successfully created."
    else
      render :new
    end
  end

  def edit
    authorize! :update, @project
  end

  def update
    authorize! :update, @project
  submitted_ids = Array(project_params[:user_ids]).map(&:to_i)
  removed_ids = @project.user_ids - submitted_ids

  if removed_ids.present?
    blocked_ids = Bug.where(project_id: @project.id)
                     .where("reporter_id IN (?) OR assignee_qa_id IN (?) OR assignee_dev_id IN (?)", removed_ids, removed_ids, removed_ids)
                     .pluck(:reporter_id, :assignee_qa_id, :assignee_dev_id)
                     .flatten.uniq & removed_ids

    if blocked_ids.present?
      blocked_names = User.where(id: blocked_ids).pluck(:name).join(", ")
      return redirect_to edit_project_path(@project), alert: "You can't remove user(s): #{blocked_names} with ongoing bugs.", status: :see_other
    end
  end

  if @project.update(project_params)
    notify_project_users
    redirect_to @project, notice: "Project was successfully updated."
  else
    @users = User.order(:name)
    render :edit, status: :unprocessable_entity
  end
end

  def destroy
    authorize! :destroy, @project
    @project.destroy
    redirect_to projects_path, notice: "Project was successfully deleted."
  end

  private

  def notify_project_users
    @project.users.each do |user|
      next if user == current_user
      Notification.create(
        recipient_id: user.id,
        message: "The project '#{@project.name}' has been updated by #{current_user.name}."
      )
    end
  end

  def assign_users
    @project = Project.find(params[:id])
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :avatar, user_ids: [])
  end
  def blocked_routes
    if !manager?
      redirect_to projects_path, alert: "You are not authorized to perform this action."
    else
      redirect_to projects_path, alert: "You cant prform this action here ."
    end
  end
end
