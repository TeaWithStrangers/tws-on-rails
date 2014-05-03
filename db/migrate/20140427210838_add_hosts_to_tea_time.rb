class AddHostsToTeaTime < ActiveRecord::Migration
  def change
    add_reference(:tea_times, :user)
  end
end
