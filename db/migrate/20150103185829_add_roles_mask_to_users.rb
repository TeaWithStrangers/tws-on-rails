class AddRolesMaskToUsers < ActiveRecord::Migration
  def up
    add_column :users, :roles_mask, :integer, default: 0
    add_index :users, :roles_mask
    old_roles = ActiveRecord::Base.connection.select_all("select * from roles_users")
    old_roles = old_roles.rows.map {|row| old_roles.columns.zip(row).to_h }.group_by {|r| r["user_id"]}
    say "Found #{old_roles.count} roles to be converted"
    failed = []
    not_found = []
    succeeded = []
    say_with_time "Converting old Roles relations to bitmask format" do
      old_roles.each do |uid, rows|
        begin
          user = User.with_deleted.find(uid)
          roles = rows.map {|r| Role.find(r['role_id']).name.downcase }
          user.roles = roles
          user.save!
          succeeded << user.id
        rescue ActiveRecord::RecordNotFound
          not_found << uid
        rescue Exception => msg
          failed << [uid, msg]
        end
      end
    end
    say "Succeeded: #{succeeded} // Not Found: #{not_found} // Failed: #{failed}"
  end

  def down
    remove_column :users, :roles_mask
    say "Don't forget to restore the has_and_belongs_to_many roles relation in the User class"
  end
end
