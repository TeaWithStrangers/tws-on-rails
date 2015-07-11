# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application

if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == 'tws' && password == ENV['TWS_DELAYED_JOBS_ADMIN_PASSWORD']
  end
end