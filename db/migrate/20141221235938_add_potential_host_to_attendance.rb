class AddPotentialHostToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :potential_host, :boolean, default: false, null: false
  end
end
