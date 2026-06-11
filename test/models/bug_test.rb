require "test_helper"

class BugTest < ActiveSupport::TestCase
  def setup
    @manager = users(:manager)
    @qa = users(:qa)
    @developer = users(:developer)
    @project = Project.create!(name: "Test Project", manager: @manager)
    @bug = Bug.new(
      project: @project,
      reporter: @qa,
      assignee_qa: @qa,
      assignee_dev: @developer,
      title: "Login bug",
      description: "Broken login flow",
      bug_type: "feature",
      status: "open"
    )
  end

  def test_feature_bug_cannot_use_resolved_status
    @bug.status = "resolved"
    assert_not @bug.save, "Feature bugs should not be saved with resolved status"
    assert @bug.errors[:status].any?, "Feature bug should add a status error"
  end

  def test_bug_cannot_use_completed_status
    @bug.bug_type = "bug"
    @bug.status = "completed"
    assert_not @bug.save, "Bug type bugs should not be saved with completed status"
    assert @bug.errors[:status].any?, "Bug type bug should add a status error"
  end

  def test_status_options_change_by_bug_type
    assert_equal [ "open", "started", "completed" ], @bug.status_options
    @bug.bug_type = "bug"
    assert_equal [ "open", "started", "resolved" ], @bug.status_options
  end
end
