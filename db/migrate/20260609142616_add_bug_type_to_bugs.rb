class AddBugTypeToBugs < ActiveRecord::Migration[8.1]
  def change
    add_column :bugs, :bug_type, :string
  end
end
