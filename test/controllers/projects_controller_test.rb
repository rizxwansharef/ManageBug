require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @manager = users(:manager)
    @qa = users(:qa)
    @dev = users(:developer)
    @project = Project.create!(name: "Original Project", manager: @manager)
  end

  def test_manager_can_edit_project
    sign_in @manager
    patch project_path(@project), params: { project: { name: "Updated Project" } }
    assert_redirected_to project_path(@project)
    @project.reload
    assert_equal "Updated Project", @project.name
  end

  def test_qa_cannot_edit_project
    sign_in @qa
    patch project_path(@project), params: { project: { name: "Malicious Update" } }
    assert_response :redirect
    @project.reload
    assert_not_equal "Malicious Update", @project.name
  end

  def test_developer_cannot_edit_project
    sign_in @dev
    patch project_path(@project), params: { project: { name: "Malicious Update" } }
    assert_response :redirect
    @project.reload
    assert_not_equal "Malicious Update", @project.name
  end

  def test_manager_can_delete_project
    sign_in @manager
    assert_difference "Project.count", -1 do
      delete project_path(@project)
    end
    assert_redirected_to projects_path
  end

  def test_qa_cannot_delete_project
    sign_in @qa
    assert_no_difference "Project.count" do
      delete project_path(@project)
    end
    assert_response :redirect
  end

  def test_developer_cannot_delete_project
    sign_in @dev
    assert_no_difference "Project.count" do
      delete project_path(@project)
    end
    assert_response :redirect
  end
end
