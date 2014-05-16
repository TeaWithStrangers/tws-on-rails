class AddHostHomeCity < ActiveRecord::Migration
  def change
    add_reference :users, :home_city
  end
end
