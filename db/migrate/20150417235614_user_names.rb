class UserNames < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :name, :nickname
      t.text :given_name
      t.text :family_name
    end
  end
end
