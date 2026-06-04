class BugsController < ApplicationController
  def index
    if manager?
      @bugs = Bug.joins(:project).where(projects: { manager_id: current_user.id })
    else
      project_ids = current_user.projects.pluck(:id)
      @bugs = Bug.where(project_id: project_ids)
    end
  end

  def show
    @bug = Bug.find(params[:id])
  end

  def new
    @bug = Bug.new
  end

  def create
    @bug = Bug.new(bug_params)
    @bug.status = 'open'
    @bug.reporter = current_user
    if @bug.save
      redirect_to @bug, notice: 'Bug was successfully created.'
    else
      render :new
    end
  end

  def edit
    @bug = Bug.find(params[:id])
  end

  def update
    @bug = Bug.find(params[:id])
    if @bug.update(bug_params)
      redirect_to @bug, notice: 'Bug was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @bug = Bug.find(params[:id])
    @bug.destroy
    redirect_to bugs_path, notice: 'Bug was successfully deleted.'
  end

  private

  def bug_params
    params.require(:bug).permit(:title, :description, :status, :project_id, :assignee_qa_id, :assignee_dev_id)
  end
end
