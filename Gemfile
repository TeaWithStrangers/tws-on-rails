ruby '2.5'

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2'
gem 'pg', '0.20'
gem 'rollbar'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', group: :doc

gem 'haml-rails', '~> 1.0'
gem 'sass-rails', '~> 5.0'

# For the old-style styles
gem 'less-rails', '~> 3.0'
gem 'therubyracer', '~> 0.12'

gem 'uglifier', '~> 4.1.6'
gem 'turbolinks'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0'
gem 'underscore-rails'
gem "active_model_serializers", "~> 0.9.3"
gem 'bitmask_attributes', '~> 1.0'
gem 'bourbon', '~> 4'
gem 'neat', '~> 1'
gem 'chosen-rails'

gem 'markerb'
gem 'redcarpet', '~> 3.4'
gem 'sendgrid'
gem 'sendgrid-ruby'

gem 'google_drive'

#Calendars
gem 'icalendar', '~> 2.2'
gem 'time_zone_ext'

#Background Jobs
gem 'delayed_job', '~> 4.1'
gem 'delayed_job_active_record'
gem "delayed_job_web"

# File Storage
gem 'paperclip', '~> 5.0'
gem 'aws-sdk', '~> 2'

# soft-delete
gem 'paranoia', "~> 2.0"

# Authentication & Permission Gems
gem 'devise', '~> 4.2'
gem 'cancancan', '~> 2.1'
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
  gem 'rspec-rails', '~> 3.7'
  gem 'rspec-activemodel-mocks'
  gem 'factory_bot', '~> 4.8'
  gem 'factory_bot_rails'
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
