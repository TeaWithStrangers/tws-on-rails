source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'

gem 'pg'

# Production monitoring
gem 'newrelic_rpm'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

#JS, CSS, Templating

gem 'haml-rails', '~> 0.5'
gem 'less-rails', '~> 2.5'
gem 'therubyracer', '~> 0.12'

gem 'uglifier', '>= 1.3.0'
# Serve Assets in Production
gem 'rails_12factor', group: :production
gem 'turbolinks'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem "active_model_serializers"


# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development
gem 'mailcatcher',        group: :development
gem 'maildown'

# Figaro makes it easy to set env variables without Foreman
#Calendars
gem 'icalendar', '~> 2.0'
gem 'time_zone_ext'

#Background Jobs
gem 'delayed_job', '~> 4.0.1'
gem 'delayed_job_active_record', '~> 4.0.1'
gem 'workless', '~> 1.2'

# File Storage
gem 'paperclip', '~> 4.1'
gem 'aws-sdk', '~> 1.5.7'

# Authentication & Permission Gems
gem 'devise', '~> 3.2.4'
gem 'cancan', '~> 1.6.10'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn', group: :production

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
gem 'debugger', group: [:development, :test]
gem 'hirb', group: :development

# Random debug tools
group :development, :test do
  gem 'pry-rails'
  gem 'pry-debugger'
  gem 'pry-stack_explorer'
  gem 'rspec-rails', '~> 2.14.2'
  gem 'factory_girl', '~>4.4'
  gem 'factory_girl_rails'
  gem 'rails-observers'
  gem 'shoulda-matchers'
end
