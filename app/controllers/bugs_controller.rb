class BugsController < ApplicationController
  before_action :set_bug, only: %i[show edit update destroy change_status]
  before_action :blocked_routes, only: %i[new ]
  before_action :available_project_scope, only: %i[index create new ]
  def index
    @available_projects = available_project_scope

    if params[:project_id].present?
        @selected_project = Project.find_by(id: params[:project_id])
        if @selected_project && (manager? && @selected_project.manager_id == current_user.id || @selected_project.users.include?(current_user))
            @bugs = @selected_project.bugs.order(created_at: :desc)
            @new_bug = Bug.new(project: @selected_project)
            @available_devs = User.joins(:projects).where(role: "developer", projects: { id: @selected_project.id }).distinct
        else
            redirect_to bugs_path, alert: "Project not found or access denied."
        end
    else
      project_scope = @available_projects
      @bugs = Bug.where(project: project_scope).distinct.order(created_at: :desc)
      @new_bug = Bug.new
      @available_devs = User.none
    end
  end


  def show
    authorize! :read, @bug
  end

  def new
    @bug = Bug.new
  end

  def create
    @bug = Bug.new(bug_params)
    @bug.status = "open"
    @bug.reporter = current_user
    @bug.assignee_qa_id =current_user.id
    if @bug.save
        Notification.create(
          recipient_id: @bug.project.manager.id,
          message: "A new bug has been created in your project '#{@bug.project.name}' by #{current_user.name}.",
        )
      redirect_to bugs_path(project_id: @bug.project_id), notice: "Bug was successfully created."
    else
      @available_projects = available_project_scope
      @selected_project = Project.find_by(id: @bug.project_id)
      project_scope = @selected_project || @available_projects
      @bugs = Bug.where(project: project_scope).distinct.order(created_at: :desc)
      @new_bug = @bug
      @new_bug.assignee_qa_id = current_user.id
      @available_devs = @selected_project ? users_for_project("developer", @selected_project) : User.none
      if @bug.errors[:title].any?
        flash.now[:alert] = "Bug name must be unique within the selected project."
      end
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    if @bug.reporter_id != current_user.id
      redirect_to bug_path(@bug), alert: "You are not authorized to edit this bug."
    else
      redirect_to bug_path(@bug), alert: "You cant prform this action here ."
    end
  end



  def update
    authorize! :update, @bug
    if @bug.update(bug_params)
      redirect_back fallback_location: @bug, notice: "Bug was successfully updated."
    else
      redirect_back fallback_location: edit_bug_path(@bug), alert: "you cant do this "
    end
  end

  def destroy
    authorize! :destroy, @bug
    @bug.destroy
    redirect_to bugs_path, notice: "Bug was successfully deleted."
  end

  def assign_developer
    @bug = Bug.find(params[:id])
          @available_devs = User.joins(:projects).where(role: "developer", projects: { id: @selected_project.id }).distinct
    Notification.create(
        recipient_id: @bug.asignee_dev_id,
        message: "You have been assigned to a new bug '#{@bug.title}' in the project  by #{current_user.name}.",
      )
  end



  def change_status

    fetched_bug_type = params[:bug_type].presence
    if fetched_bug_type && fetched_bug_type =="bug"
     allowed_statuses = %w[new started resolved]
    elsif fetched_bug_type && fetched_bug_type =="feature"
      allowed_statuses = %w[new started completed]
    end

      if allowed_statuses.include?(params[:status])
        @bug.status = params[:status]
        if @bug.save  
            Notification.create(
              recipient_id: @bug.reporter_id,
              message: "The status of your reported bug '#{@bug.title}' has been changed to '#{@bug.status}'.",
            )
            redirect_back fallback_location: bug_path(@bug), notice: "Bug status was successfully updated."
        end
      end
  end

  private

  def available_project_scope
    manager? ? Project.where(manager_id: current_user.id) : current_user.projects
  end

  def users_for_project(role, project)
    User.joins(:projects).where(role: role, projects: { id: project.id }).distinct.order(:name)
  end

  def set_bug
    @bug = Bug.find_by(id: params[:id])
    unless @bug
      redirect_to bugs_path, alert: "Bug not found."
    end
  end

  def bug_params
    params.require(:bug).permit(:title, :description, :bug_type, :status, :project_id, :assignee_qa_id, :assignee_dev_id, :screenshot, :deadline)

  end
  def blocked_routes
    if !qa?
      redirect_to projects_path, alert: "You are not authorized to perform this action."
    else
      redirect_to projects_path, alert: "You cant prform this action here ."
    end
  end
end
