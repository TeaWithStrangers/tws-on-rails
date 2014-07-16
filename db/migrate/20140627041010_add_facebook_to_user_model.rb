class AddFacebookToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :facebook, :string
  end
end
