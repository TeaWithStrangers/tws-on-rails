namespace :db do
  desc 'Create some play data for development database. Safe to run multiple times'
  task :seed_dev => :environment do

    puts "Resetting database"
    %x[rake db:reset]

    puts "Loading seeds_dev"
    load "#{Rails.root}/db/seeds_dev.rb"
  end

  desc "Update Cities users_count counter cache"
  task update_users_counter_cache: :environment do
    City.find_each { |city| City.reset_counters(city.id, :users) }
  end
end
