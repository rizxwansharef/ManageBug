require "test_helper"

class BugsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @manager = users(:manager)
    @qa = users(:qa)
    @developer = users(:developer)
    @project = Project.create!(name: "Bug Project", manager: @manager)
    ProjectAssignment.create!(project: @project, user: @qa)
    ProjectAssignment.create!(project: @project, user: @developer)
    @bug = Bug.create!(
      project: @project,
      reporter: @qa,
      assignee_qa: @qa,
      assignee_dev: @developer,
      title: "Feature bug",
      description: "Feature should be completed",
      bug_type: "feature",
      status: "open"
    )
  end

  def test_manager_cannot_update_bug
    sign_in @manager
    patch bug_path(@bug), params: { bug: { status: "started" }, commit: "Save" }
    assert_response :redirect
    @bug.reload
    assert_equal "open", @bug.status
  end

  def test_manager_cannot_destroy_bug
    sign_in @manager
    assert_no_difference "Bug.count" do
      delete bug_path(@bug)
    end
    assert_response :redirect
  end

  def test_developer_cannot_update_feature_bug_to_resolved_status
    sign_in @developer
    patch bug_path(@bug), params: { bug: { status: "resolved" }, commit: "Save" }
    assert_response :redirect
    @bug.reload
    assert_equal "open", @bug.status
  end

  def test_feature_bug_rejects_resolved_status_update
    sign_in @developer
    patch change_status_bug_path(@bug), params: { status: "resolved" }
    assert_response :redirect
    @bug.reload
    assert_equal "open", @bug.status
  end
end
