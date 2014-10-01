class AddDeleteAtToTeaTimesAndAttendances < ActiveRecord::Migration
  def change
    add_column :users, :deleted_at, :datetime, index: true
    add_column :tea_times, :deleted_at, :datetime, index: true
    add_column :attendances, :deleted_at, :datetime, index: true
  end
end
