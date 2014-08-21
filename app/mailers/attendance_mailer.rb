class AttendanceMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines

  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def registration(attendance_id)
    @attendance = Attendance.find(attendance_id)
    @tea_time = @attendance.tea_time
    @user = @attendance.user

    mail.attachments['event.ics'] = {mime_type: "text/calendar", 
                                     content: @tea_time.ical.to_ical}

    mail(to: @attendance.user.email,
         from: @tea_time.host.friendly_email,
         subject: "See you at tea time!",
         reply_to: @tea_time.host.email)
  end

  def reminder(attendance_id, type)
    @attendance = Attendance.find(attendance_id)
    @user = @attendance.user
    @type = type
    tt = @attendance.tea_time
    
    mail.attachments['event.ics'] = {mime_type: "text/calendar", 
                                     content: @attendance.tea_time.ical.to_ical}
    cancel_delivery unless @attendance.pending?

    mail(to: @attendance.user.email, 
         from: @attendance.tea_time.host.email,
         subject: "See you at tea time soon!") 
  end

  def flake(attendance_id)
    attendance = Attendance.find(attendance_id)
    @user = attendance.user
    @tea_time = attendance.tea_time
    mail(to: @user.email, 
         from: @tea_time.host.friendly_email,
         reply_to: @tea_time.host.email,
         subject: "Let's find another tea time that works!")
  end
end
