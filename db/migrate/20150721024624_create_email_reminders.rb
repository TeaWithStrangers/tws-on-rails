class CreateEmailReminders < ActiveRecord::Migration
  def change
    create_table :email_reminders do |t|
      t.integer :remindable_id
      t.string :remindable_type
      t.text :body
      t.integer :t_minus_in_hours

      t.timestamps null: true
    end
  end
end
