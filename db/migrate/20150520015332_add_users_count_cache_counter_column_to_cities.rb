class AddUsersCountCacheCounterColumnToCities < ActiveRecord::Migration
  def change
    add_column :cities, :users_count, :integer, default: 0
  end
end
