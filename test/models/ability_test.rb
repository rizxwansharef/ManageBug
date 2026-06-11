require "test_helper"

class AbilityTest < ActiveSupport::TestCase
  def setup
    @manager = users(:manager)
    @qa = users(:qa)
    @developer = users(:developer)
    @manager2 = User.create!(name: "Manager2", email: "other@example.com", password: "Password123!", role: "manager")
    @qa2 = User.create!(name: "QA2", email: "other_qa@example.com", password: "Password123!", role: "qa")
    
    @project = Project.create!(name: "Test Project", manager: @manager)
    @project2 = Project.create!(name: "Test Project2", manager: @manager2)
    
    @project.users << @qa
    @project.users << @developer
    
    @bug = Bug.create!(
      project: @project,
      reporter: @qa,
      assignee_qa: @qa,
      assignee_dev: @developer,
      title: "Test Bug",
      description: "Bug details",
      bug_type: "bug",
      status: "open"
    )
    
    @bug2 = Bug.create!(
      project: @project2,
      reporter: @qa2,
      assignee_qa: @qa2,
      assignee_dev: @qa2,
      title: "Bug2 ",
      description: "bug 2 details",
      bug_type: "bug",
      status: "open"
    )
  end

  def test_manager_can_manage_their_own_projects 
    ability = Ability.new(@manager)
    assert ability.can?(:manage, @project)
    assert ability.cannot?(:manage, @project2)
  end

  def test_manager_cannot_create_or_update_bugs
    ability = Ability.new(@manager)
    assert ability.can?(:read, @bug)
    assert ability.cannot?(:create, Bug)
    assert ability.cannot?(:update, @bug)
    assert ability.cannot?(:destroy, @bug)
    assert ability.cannot?(:change_status, @bug)
  end

  def test_qa_can_read_assigned_project_and_bugs
    ability = Ability.new(@qa)
    assert ability.can?(:read, @project)
    assert ability.cannot?(:read, @project2)
    assert ability.can?(:read, @bug)
    assert ability.cannot?(:read, @bug2)
  end

  def test_qa_cannot_create_update_destroy_project
    ability = Ability.new(@qa)
    assert ability.cannot?(:create, Project)
    assert ability.cannot?(:update, @project)
    assert ability.cannot?(:destroy, @project)
  end

  def test_qa_can_create_bug_in_assigned_project
    ability = Ability.new(@qa)
    new_bug = Bug.new(project: @project)
    assert ability.can?(:create, new_bug)
    
    new_bug2 = Bug.new(project: @project2)
    assert ability.cannot?(:create, new_bug2)

  end

  def test_qa_can_update_and_destroy_bugs_they_reported
    ability = Ability.new(@qa)
    assert ability.can?(:update, @bug)
    assert ability.can?(:destroy, @bug)
    assert ability.can?(:change_status, @bug)
    
    assert ability.cannot?(:update, @bug2)
    assert ability.cannot?(:destroy, @bug2)
  end

  def test_developer_can_read_assigned_project_and_bugs
    ability = Ability.new(@developer)
    assert ability.can?(:read, @project)
    assert ability.cannot?(:read, @project2)
    assert ability.can?(:read, @bug)
    assert ability.cannot?(:read, @bug2)
  end

  def test_developer_cannot_manage_projects_or_create_destroy_bugs 
    ability = Ability.new(@developer)
    assert ability.cannot?(:create, Project)
    assert ability.cannot?(:update, @project)
    
    assert ability.cannot?(:create, Bug)
    assert ability.cannot?(:destroy, @bug)
  end

  def test_developer_can_update_and_change_status_of_assigned_bugs
    ability = Ability.new(@developer)
    assert ability.can?(:update, @bug)
    assert ability.can?(:change_status, @bug)
    
    assert ability.cannot?(:update, @bug2)
    assert ability.cannot?(:change_status, @bug2)
  end
end
