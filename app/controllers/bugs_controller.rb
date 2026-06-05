class BugsController < ApplicationController
  before_action :set_bug, only: %i[show edit update destroy change_status]

  def index
    if params[:project_id].present?
        @selected_project = Project.find_by(id: params[:project_id])
        if @selected_project && (manager? && @selected_project.manager_id == current_user.id || @selected_project.users.include?(current_user))
            @bugs = @selected_project.bugs.order(created_at: :desc)
            @new_bug = Bug.new(project: @selected_project)
            @available_qas = User.joins(:projects).where(role: "qa", projects: { id: @selected_project.id }).distinct
            @available_devs = User.joins(:projects).where(role: "developer", projects: { id: @selected_project.id }).distinct
        else
            redirect_to bugs_path, alert: "Project not found or access denied."
        end
    else
      project_scope = manager? ? Project.where(manager_id: current_user.id) : current_user.projects
      @bugs = Bug.where(project: project_scope).distinct.order(created_at: :desc)
    end
  end


  def show
  end

  def new
    @bug = Bug.new
  end

  def create
    @bug = Bug.new(bug_params)
    @bug.status = "open"
    @bug.reporter = current_user
    if @bug.save
        Notification.create(
          recipient_id: @bug.project.manager.id,
          message: "A new bug has been created in your project '#{@bug.project.name}' by #{current_user.name}.",
        )
      redirect_to bugs_path(project_id: @bug.project_id), notice: "Bug was successfully created."
    else

      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @bug.update(bug_params)
      redirect_back fallback_location: @bug, notice: "Bug was successfully updated."
    else
      redirect_back fallback_location: edit_bug_path(@bug), alert: @bug.errors.full_messages.to_sentence
    end
  end

  def destroy
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

  def assign_qa
    @bug = Bug.find(params[:id])
     @available_qas = User.joins(:projects).where(role: "qa", projects: { id: @selected_project.id }).distinct
    Notification.create(
        recipient_id: @bug.asignee_qa_id,
        message: "You have been assigned to a new bug '#{@bug.title}' in the project  by #{current_user.name}.",
      )
  end

  def change_status
    requested_status = params[:status].presence
    allowed_statuses = %w[open in_progress resolved]

    if requested_status.in?(allowed_statuses)
      @bug.update(status: requested_status)
    elsif @bug.status == "open" && @bug.assignee_dev_id.present?
      @bug.update(status: "in_progress")
    elsif @bug.status == "in_progress" && @bug.assignee_qa_id.present?
      @bug.update(status: "resolved")
    end
    Notification.create(
      recipient_id: @bug.reporter_id,
      message: "The status of your reported bug '#{@bug.title}' has been changed to '#{@bug.status}'.",
    )
    redirect_back fallback_location: bug_path(@bug), notice: "Bug status was successfully updated."
  end

  private

  def set_bug
    @bug = Bug.find(params[:id])
  end


  def bug_params
    params.require(:bug).permit(:title, :description, :status, :project_id, :assignee_qa_id, :assignee_dev_id, :screenshot, :deadline)
  end
end
