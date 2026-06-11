require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  def test_manager_can_create_project
    project = Project.new(name: "Test Project", manager: users(:manager))
    assert project.save, "Project should be saved when manager role is manager"
  end

  def test_qa_cannot_create_project
    project = Project.new(name: "Test Project", manager: users(:qa))
    assert_not project.save, "Project should not be saved when manager role is not manager"
  end

  def test_developer_cannot_create_project
    project = Project.new(name: "Test Project", manager: users(:developer))
    assert_not project.save, "Project should not be saved when manager role is developer"
  end
end
