class TeaTimeMailer < ActionMailer::Base
  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def host_confirmation(tea_time)
    @tea_time = tea_time
    mail.attachments['event.ics'] = {mime_type: "text/calendar", 
                                     content: @tea_time.ical.to_ical}

    mail(to: tea_time.host.email, 
         subject: "Tea Time Confirmation for #{@tea_time.friendly_time}").
    deliver!

  def registration(attendance)
    @attendance = attendance
    @tea_time = attendance.tea_time
    @user = attendance.user

    mail.attachments['event.ics'] = {mime_type: "text/calendar", 
                                     content: @tea_time.ical.to_ical}

    mail(to: attendance.user.email, subject: "See you at tea time!").deliver!
  end

  def reminder(attendance)
    @attendance = attendance
    @user = attendance.user
    tt = attendance.tea_time
    
    mail.attachments['event.ics'] = {mime_type: "text/calendar", 
                                     content: @attendance.tea_time.ical.to_ical}

    mail(from: "\"#{tt.host.name}\" <#{tt.host.email}>", 
         to: @user.email, 
         subject: "Confirming tea time", 
         reply_to: tt.host.email).
         deliver!
  end

  def cancellation(tea_time)
    @tea_time = tea_time
    tea_time.attendances.each do |att|
      @user = att.user 
      mail(to: @user.email, subject: "Sad days — tea time canceled").deliver!
    end
  end

  def flake(attendance)
    @user = attendance.user
    @tea_time = attendance.tea_time
    mail(to: @user.email, subject: "Let's find another tea time that works!").deliver!
  end
end
