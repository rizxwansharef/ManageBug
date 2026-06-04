class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.integer :recipient_id, null: false
      t.string :message, null: false
      t.boolean :read, default: false
      t.timestamps
    end
  end
end
