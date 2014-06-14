namespace :db do
  desc "Creates roles for dev database"
  task :create_roles => :environment do
    %w{Admin Host}.each {|r| Role.create(name: r) }
  end

  desc 'Create some play data for development database. Safe to run multiple times'
  task :seed_dev => :environment do

    puts "Resetting database"
    %x[rake db:reset]

    puts "Creating roles"
    %x[rake db:create_roles]

    puts "Loading seeds_dev"
    load "#{Rails.root}/db/seeds_dev.rb"
  end
end
