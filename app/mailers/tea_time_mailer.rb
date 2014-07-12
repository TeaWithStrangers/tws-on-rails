class TeaTimeMailer < ActionMailer::Base
  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def host_confirmation(tea_time)
    @tea_time = tea_time
    mail.attachments['event.ics'] = {mime_type: "text/calendar", 
                                     content: @tea_time.ical.to_ical}

    mail(to: tea_time.host.email, 
         subject: "Tea Time Confirmation for #{@tea_time.friendly_time}").deliver!
  end

  def registration(attendance)
    @attendance = attendance
    @tea_time = attendance.tea_time
    @user = attendance.user

    mail.attachments['event.ics'] = {mime_type: "text/calendar", 
                                     content: @tea_time.ical.to_ical}

    mail(to: attendance.user.email, 
         from: @tea_time.host.friendly_email,
         subject: "See you at tea time!",
         reply_to: @tea_time.host.email).deliver!
  end

  def reminder(attendance_id, type)
    @attendance = Attendance.find(attendance_id)
    @user = @attendance.user
    @type = type
    tt = @attendance.tea_time
    
    mail.attachments['event.ics'] = {mime_type: "text/calendar", 
                                     content: @attendance.tea_time.ical.to_ical}

    # We shouldn't send a reminder for a flake
    if @attendance.pending?
      mail(to: @user.email, 
           from: tt.host.friendly_email,
           subject: "See you at tea time soon!", 
           reply_to: tt.host.email).deliver!
    end
  end

  def followup(tea_time)
    unless tea_time.cancelled?
      as = tea_time.attendances.group_by(&:status)
      @tea_time = tea_time
      as.each do |type, attendees|
        case type
        when 'flake'
          template = 'followup_flake_noresched'
        when 'no_show'
          template = 'followup_no_show'
        else
          template = 'followup'
        end
        mail(bcc: attendees.map {|a| a.user.email},
             from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
             subject: 'Following up on tea time',
             template_name: template).deliver!
      end
    end
  end

  def ethos(user_id)
    @user = User.find(user_id)
    mail(to: @user.email,
         from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
         subject: "What tea time is about",
         template_name: 'registration_followup').deliver!
  end

  def cancellation(tea_time)
    @tea_time = tea_time
    @tea_time.attendances.map do |att|
      @user = att.user 
      mail(to: @user.email, subject: "Sad days — tea time canceled").deliver!
    end
  end

  def flake(attendance_id)
    attendance = Attendance.find(attendance_id)
    @user = attendance.user
    @tea_time = attendance.tea_time
    mail(to: @user.email, 
         from: @tea_time.host.friendly_email,
         reply_to: @tea_time.host.email,
         subject: "Let's find another tea time that works!").deliver!
  end
end
