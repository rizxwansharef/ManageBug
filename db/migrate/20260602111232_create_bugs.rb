class CreateBugs < ActiveRecord::Migration[8.1]
  def change
    create_table :bugs do |t|
      t.string :title
      t.text :description
      t.string :status
      t.datetime :reported_at
      t.datetime :deadline

      t.references :project, null: false, foreign_key: true
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :assignee_qa, null: false, foreign_key: { to_table: :users }
      t.references :assignee_dev, null: false, foreign_key: { to_table: :users }
      
      t.timestamps
    end
  end
end
