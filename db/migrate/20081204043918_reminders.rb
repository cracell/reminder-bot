class Reminders < ActiveRecord::Migration
  def self.up
    create_table :reminders do |t|
      t.string 'user'
      t.string "reminder"
      t.datetime "remind_at"
      t.timestamps
    end
    
    add_index(:reminders, :remind_at)
    add_index(:reminders, :user)
  end

  def self.down
    drop_table :reminders
  end
end
