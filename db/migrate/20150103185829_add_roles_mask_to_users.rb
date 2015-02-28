class AddRolesMaskToUsers < ActiveRecord::Migration
  def up
    add_column :users, :roles, :integer, default: 0, null: false
    Rake::Task['roles:relations_to_bitmask'].invoke
  end

  def down
    remove_column :users, :roles
    say "Don't forget to restore the has_and_belongs_to_many roles relation in the User class"
  end
end
