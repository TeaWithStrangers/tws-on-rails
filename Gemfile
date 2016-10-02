ruby '2.1.5'

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.1'
gem 'pg'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'haml-rails', '~> 0.5'
gem 'sass-rails', '~> 5.0'

# For the old-style styles
gem 'less-rails', '~> 2.5'
gem 'therubyracer', '~> 0.12'

gem 'uglifier', '>= 1.3.0'
gem 'turbolinks'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0'
gem 'underscore-rails'
gem "active_model_serializers"
gem 'bitmask_attributes', '~> 1.0'
gem 'bourbon'
gem 'neat'

gem 'markerb'
gem 'sendgrid'

gem 'google_drive'

# Figaro makes it easy to set env variables without Foreman
#Calendars
gem 'icalendar', '~> 2.2'
gem 'time_zone_ext'

#Background Jobs
gem 'delayed_job', '~> 4.0.1'
gem 'delayed_job_active_record', '~> 4.0.1'
gem "delayed_job_web"

# File Storage
gem 'paperclip', '~> 4.1'
gem 'aws-sdk', '~> 1.5.7'

# soft-delete
gem 'paranoia', "~> 2.0"

# Authentication & Permission Gems
gem 'devise', '~> 3.2.4'
gem 'cancan', '~> 1.6.10'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use same server in dev as production
gem 'unicorn'
gem 'unicorn-rails'

gem 'will_paginate'

group :production do
  gem 'newrelic_rpm'
  gem 'skylight'
  gem 'rails_12factor'
end

group :development do
  gem 'spring'
end

# Random debug tools
group :development, :test do
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'rspec-rails', '~> 2.14.2'
  gem 'factory_girl', '~>4.4'
  gem 'factory_girl_rails'
  gem 'rails-observers'
  gem 'shoulda-matchers', require: false
  gem 'coveralls', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'capybara'
  gem 'guard'
  gem 'guard-zeus'
end
