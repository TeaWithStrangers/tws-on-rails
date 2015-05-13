class AddSuggestedByUserToCities < ActiveRecord::Migration
  def change
    add_column :cities, :suggested_by_user_id, :integer
  end
end
