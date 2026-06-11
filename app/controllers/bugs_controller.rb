class BugsController < ApplicationController
  before_action :set_bug, only: %i[show edit update destroy change_status]
  # useless

  def index
    @available_projects = available_project_scope
    if params[:project_id].present?
      @selected_project = Project.find_by(id: params[:project_id])
      if @selected_project && can?(:read, @selected_project)
        @bugs = @selected_project.bugs.order(created_at: :desc)
        @new_bug = Bug.new(project: @selected_project)
        @available_devs = @selected_project.users.developer
      else
        redirect_to bugs_path, alert: "Project not found or access denied."
      end
    else
      @bugs = Bug.where(project: @available_projects).distinct.order(created_at: :desc)
      @new_bug = Bug.new
      @available_devs = User.none
    end
  end

  def show
    authorize! :read, @bug
  end

  def create
    @bug = Bug.new(bug_params)
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
      render :new, alert: @bug.errors.full_messages.to_sentence
    end
  end

  def update
    authorize! :update, @bug
    if params[:commit]
      if @bug.update(bug_params)
        redirect_back fallback_location: @bug, notice: "Bug was successfully updated."
      else
        redirect_back fallback_location: bug_path(@bug), alert: @bug.errors.full_messages.to_sentence
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

  def change_status
    if @bug.update(status: params[:status])
      Notification.create(
        recipient_id: @bug.reporter_id,
        message: "The status of your reported bug '#{@bug.title}' has been changed to '#{@bug.status}'.",
      )
      redirect_back fallback_location: bug_path(@bug), notice: "Bug status was successfully updated."
    else
      redirect_back fallback_location: bug_path(@bug), alert: @bug.errors.full_messages.to_sentence
    end
  end

  private

  def available_project_scope
    manager? ? Project.where(manager_id: current_user.id) : current_user.projects
  end

  def users_for_project(role, project)
    User.where(role: role, projects: { id: project.id }).distinct.order(:name)
  end

  def set_bug
    @bug = Bug.find_by(id: params[:id])
  end

  def bug_params
    allowed_fields = if developer?
      [ :status ]
    else
      [ :project_id, :title, :description, :bug_type, :status, :assignee_dev_id, :screenshot, :deadline ]
    end

    params.require(:bug).permit(allowed_fields)
  end
end
