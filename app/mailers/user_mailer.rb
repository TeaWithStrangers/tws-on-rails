class UserMailer < ActionMailer::Base
  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def user_registration(user, password)
    @user = user; @password=password;
    mail(from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
         to: @user.email, 
         subject: 'High fives from Tea With Strangers!').
         deliver!
  end

  def tea_time_registration(attendance)
    @attendance = attendance
    @tea_time = attendance.tea_time
    @user = attendance.user

    mail.attachments['event.ics'] = {mime_type: "text/calendar", content: @tea_time.ical.to_ical}
    mail(to: attendance.user.email, subject: "See you at tea time!").deliver!
  end

  def tea_time_reminder(attendance)
    @attendance = attendance
    @user = attendance.user
    tt = attendance.tea_time
    
    mail(from: "\"#{tt.host.name}\" <#{tt.host.email}>", 
         to: attendance.user.email, 
         subject: "Confirming Tea Time tomorrow", 
         reply_to: tt.host.email).
         deliver!
  end

  def tea_time_cancellation(tea_time)
    @tea_time = tea_time
    tea_time.attendances.each do |att|
      @user = att.user 
      mail(to: @user.email, subject: "Sad days — tea time canceled").deliver!
    end
  end

  def tea_time_flake(attendance)
    @user = attendance.user
    @tea_time = attendance.tea_time
    mail(to: @user.email, subject: "Let's find another tea time that works!").deliver!
  end
end
