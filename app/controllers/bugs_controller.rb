class BugsController < ApplicationController
  before_action :set_bug, only: %i[show edit update destroy change_status]
  before_action :blocked_routes, only: %i[new edit]
  before_action :available_project_scope, only: %i[index create new ]
  def index
    @available_projects = available_project_scope

    if params[:project_id].present?
        @selected_project = Project.find_by(id: params[:project_id])
        if @selected_project && can?(:read, @selected_project)
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
    @bug.assignee_qa_id = current_user.id

    if params[:commit].blank?
      return respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(@bug, :status_container),
            partial: "bugs/status_select",
            locals: { bug: @bug }
          )
        end
        format.html { render partial: "bugs/edit_form", locals: { bug: @bug } }
      end
    end

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
    authorize! :update, @bug
  end



  def update
    authorize! :update, @bug

    if params[:commit]
      if @bug.update(bug_params)
        redirect_back fallback_location: @bug, notice: "Bug was successfully updated."
      else
        redirect_back fallback_location: edit_bug_path(@bug), alert: @bug.errors.full_messages.to_sentence
      end
    else
      @bug.assign_attributes(bug_params)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(@bug, :status_container),
            partial: "bugs/status_select",
            locals: { bug: @bug }
          )
        end
        format.html { render partial: "bugs/edit_form", locals: { bug: @bug } }
      end
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
    authorize! :change_status, @bug
    return redirect_back fallback_location: bug_path(@bug), alert: "Invalid status." unless @bug.status_options.include?(params[:status])

    @bug.update!(status: params[:status])
    Notification.create(
      recipient_id: @bug.reporter_id,
      message: "The status of your reported bug '#{@bug.title}' has been changed to '#{@bug.status}'.",
    )
    redirect_back fallback_location: bug_path(@bug), notice: "Bug status was successfully updated."
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
    allowed_fields = if developer?
      [ :status ]
    else
      [ :title, :description, :bug_type, :status, :assignee_dev_id, :screenshot, :deadline ]
    end

    params.require(:bug).permit(allowed_fields)
  end


  def blocked_routes
    if !qa?
      redirect_to projects_path, alert: "You are not authorized to perform this action."
    else
      redirect_to projects_path, alert: "You cant prform this action here ."
    end
  end
end
