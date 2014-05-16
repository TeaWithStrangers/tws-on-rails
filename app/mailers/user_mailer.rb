class UserMailer < ActionMailer::Base
  default from: "sayhi@teawithstrangers.com"

  def user_registration(user, password)
    @user = user; @password=password;
    mail(from: 'ankit@teawithstrangers.com',
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

    mail(to: attendance.user.email, subject: "See you at tea time!", 
         reply_to: tt.host.email).deliver!
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
    mail(to: @user.email, subject: "Let's find another tea time that works for you!").deliver!
  end
end
