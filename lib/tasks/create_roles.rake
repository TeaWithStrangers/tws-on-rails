namespace :db do
  namespace :dev do
    desc "Creates roles for dev database"
    task :create_roles => :environment do
      %w{Admin Host}.each {|r| Role.create(name: r) }
    end
  end
end