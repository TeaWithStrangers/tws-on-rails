class AttendanceMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines

  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  # Sent to a user confirming their registration for a tea time
  def registration(attendance_id)
    sendgrid_category "Tea Time Registration"

    @attendance = Attendance.find(attendance_id)
    @tea_time = @attendance.tea_time
    @user = @attendance.user

    mail.attachments['event.ics'] = {mime_type: "text/calendar",
                                     content: @tea_time.ical.to_ical}

    mail(to: @attendance.user.email,
         from: @tea_time.host.friendly_email,
         subject: "See you at tea time #{@attendance.user.name}!",
         reply_to: @tea_time.host.email) do |format|
           format.text
           format.html
         end
  end

  # Twelve-hour and two day reminder of a tea time a user is attending
  def reminder(attendance_id, type)
    sendgrid_category "Tea Time Reminder"

    @attendance = Attendance.find(attendance_id)
    @user = @attendance.user
    @type = type
    tt = @attendance.tea_time

    mail.attachments['event.ics'] = {mime_type: "text/calendar",
                                     content: @attendance.tea_time.ical.to_ical}
    cancel_delivery unless @attendance.pending?

    mail(to: @attendance.user.email,
         from: @attendance.tea_time.host.email,
         subject: "See you at tea time soon!") do |format|
      format.text
      format.html
    end
  end

  # Sent to user to confirm that their flake has been recorded
  def flake(attendance_id)
    sendgrid_category "Flake Confirmation"

    attendance = Attendance.find(attendance_id)
    @user = attendance.user
    @tea_time = attendance.tea_time
    mail(to: @user.email,
         from: @tea_time.host.friendly_email,
         reply_to: @tea_time.host.email,
         subject: "Come to another tea time?") do |format|
      format.text
      format.html
    end
  end


  # Informs user they've been enroled on the waitlist
  def waitlist(attendance_id)
    sendgrid_category 'Waitlist Enrolment'

    @attendance = Attendance.find(attendance_id)
    @tea_time = @attendance.tea_time
    @user = @attendance.user

    mail(to: @attendance.user.email,
         from: @tea_time.host.friendly_email,
         subject: "You're on the wait list for tea time on #{@tea_time.start_time.strftime('%B %-e')}!",
         reply_to: @tea_time.host.email) do |format|
      format.text
      format.html
    end
  end

  # Sent to all users currently on the waitlist
  def waitlist_free_spot(tea_time_id)
    sendgrid_category "Waitlist Spot Availability Notification"

    @tea_time = TeaTime.find(tea_time_id)

    waitlist = @tea_time.attendances.select(&:waiting_list?)
    mail(bcc: waitlist.map {|a| a.user.email},
         from: @tea_time.host.friendly_email,
         subject: 'A spot just opened up at tea time! Sign up!',
         reply_to: @tea_time.host.email) do |format|
      format.text
      format.html
    end
  end

  def mark_attendance_reminder(tea_time_id)
    @tea_time = TeaTime.find(tea_time_id)
    @host = @tea_time.host

    mail(to: host.friendly_email,
         subject: "Don't forget to mark attendance for your last tea time!") do |format|
      format.text
      format.html
    end
  end
end
