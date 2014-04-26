class UsersHaveAndBelongToManyRoles < ActiveRecord::Migration
  def change
    create_table :roles_users do |t|
      t.references :role, :user
    end
  end
end
