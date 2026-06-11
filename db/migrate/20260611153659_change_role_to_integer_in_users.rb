class ChangeRoleToIntegerInUsers < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE users SET role = '0' WHERE role = 'manager'"
    execute "UPDATE users SET role = '1' WHERE role = 'qa'"
    execute "UPDATE users SET role = '2' WHERE role = 'developer'"
    
    change_column :users, :role, :integer, default: 0, null: false
  end

  def down
    change_column :users, :role, :string
  end
end
