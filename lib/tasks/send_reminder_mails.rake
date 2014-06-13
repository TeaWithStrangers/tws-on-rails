namespace :email do
  desc 'Send Tea Time attendees a reminder they have a tea time today'
  task :reminders => :environment do
    today = DateTime.now.utc.midnight
    TeaTime.where(start_time: (today..(today+1.day))).each do |tt|
      tt.attendances.each do |a|
        #Mail the user a reminder
        begin
          UserMailer.tea_time_reminder(a) if a.pending?
        rescue => ex
          Rails.logger.error "Failed Mail: #{ex.message}"
        end
      end
    end
  end
end
