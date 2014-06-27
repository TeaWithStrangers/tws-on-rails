namespace :db do
  desc 'Create some play data for development database. Safe to run multiple times'
  task :seed_dev => :environment do

    puts "Resetting database"
    %x[rake db:reset]

    puts "Loading seeds_dev"
    load "#{Rails.root}/db/seeds_dev.rb"
  end
end
