class AddUseCustomEmailReminderOnTeaTimes < ActiveRecord::Migration
  def change
    add_column :tea_times, :use_custom_email_reminder, :boolean, default: true
  end
end
