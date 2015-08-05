class AddProvidePhoneNumberColumnToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :provide_phone_number, :boolean, default: false
  end
end
