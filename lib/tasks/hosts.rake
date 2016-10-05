namespace :hosts do
    desc 'Refresh Activity Status for all Hosts'
    task :refresh_activity_status => [:environment] do
      RefreshHostActivityStatus.run
    end
end
