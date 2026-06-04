class BugsController < ApplicationController
  before_action :set_bug, only: %i[show edit update destroy change_status]

  def index
    if manager?
      @bugs = Bug.joins(:project).where(projects: { manager_id: current_user.id })
    else
      project_ids = current_user.projects.pluck(:id)
      @bugs = Bug.where(project_id: project_ids)
    end
  end

  def show
  end

  def new
    @bug = Bug.new
  end

  def create
    @projects= current_user.projects
    @bug = Bug.new(bug_params)
    @bug.status = 'open'
    @bug.reporter = current_user
    if @bug.save
        Notification.create(
          recipient_id: @bug.project.manager.id,
          message: "A new bug has been created in your project '#{@bug.project.name}' by #{current_user.name}.",
        )
      redirect_to @bug, notice: 'Bug was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @bug.update(bug_params)
      redirect_to @bug, notice: 'Bug was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @bug.destroy
    redirect_to bugs_path, notice: 'Bug was successfully deleted.'
  end

  def assign_developer
    @bug = Bug.find(params[:id])
    @developers = User.where(role: 'developer', projects: { id: @bug.project_id }).distinct
    Notification.create(
        recipient_id: @bug.asignee_dev_id,
        message: "You have been assigned to a new bug '#{@bug.title}' in the project  by #{current_user.name}.",
      )
  end   

  def assign_qa
    @bug = Bug.find(params[:id])  
    @qas = User.where(role: 'qa', projects: { id: @bug.project_id }).distinct
    Notification.create(
        recipient_id: @bug.asignee_qa_id,
        message: "You have been assigned to a new bug '#{@bug.title}' in the project  by #{current_user.name}.",
      )
  end

  def change_status
    if @bug.status == 'open' && @bug.assignee_dev_id.present?
      @bug.update(status: 'in_progress')
    elsif @bug.status == 'in_progress' && @bug.assignee_qa_id.present?
      @bug.update(status: 'resolved')
    end
    Notification.create(
      recipient_id: @bug.reporter_id,
      message: "The status of your reported bug '#{@bug.title}' has been changed to '#{@bug.status}'.",
    )   
    redirect_to @bug, notice: 'Bug status was successfully updated.'
  end

  private

  def set_bug
    @bug = Bug.find(params[:id])
  end

  
  def bug_params
    params.require(:bug).permit(:title, :description, :status, :project_id, :assignee_qa_id, :assignee_dev_id, :screenshot)
  end
end
