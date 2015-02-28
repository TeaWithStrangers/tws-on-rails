namespace :roles do
  desc 'Migrate Roles from roles_users table to bitmask on Users table'
  task :relations_to_bitmask => [:environment] do
    User.reset_column_information
    old_roles = ActiveRecord::Base.connection.select_all("select * from roles_users")
    old_roles = old_roles.rows.map {|row| old_roles.columns.zip(row).to_h }.group_by {|r| r["user_id"]}
    Rails.logger.info "Found #{old_roles.count} roles to be converted"
    failed = []
    not_found = []
    succeeded = []

    old_roles.each do |uid, rows|
      begin
        user = User.with_deleted.find(uid)
        roles = rows.map {|r| Role.find(r['role_id']).name.downcase.to_sym }
        if !roles.empty?
          user.roles = roles
          user.save
          raise Exception unless user.reload.roles.sort == roles.sort
        end
        succeeded << user.id
      rescue ActiveRecord::RecordNotFound
        not_found << uid
      rescue Exception => msg
        failed << [uid, msg]
      end
    end

    Rails.logger.info "Succeeded: #{succeeded} // Not Found: #{not_found} // Failed: #{failed}"
  end
end
