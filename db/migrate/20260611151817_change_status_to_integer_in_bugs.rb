class ChangeStatusToIntegerInBugs < ActiveRecord::Migration[8.1]
  def change
    change_column :bugs, :status, :integer, default: 0
  end
end
