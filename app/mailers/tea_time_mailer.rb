class TeaTimeMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines

  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def host_confirmation(tea_time_id)
    sendgrid_category "Tea Time: Creation Confirmation for Host"

    @tea_time = TeaTime.find(tea_time_id)
    mail.attachments['event.ics'] = {mime_type: "text/calendar",
                                     content: @tea_time.ical.to_ical}

    mail(to: @tea_time.host.email,
         subject: "Add your tea time (#{@tea_time.start_time.strftime("%-m/%-d, %-l:%M - ")}#{(@tea_time.start_time+2.hours).strftime("%-l:%M%P")}) to the calendar!") do |format|
      format.text
      format.html
    end
  end

  def host_changed(tea_time_id, old_host_id)
    sendgrid_category "Tea Time Host Changed"

    @tt = TeaTime.find(tea_time_id)
    @old, @new = [User.find(old_host_id), @tt.host]
    mail(to: @new.friendly_email,
         cc: ['ankit@teawithstrangers.com', @old.friendly_email],
         subject: "You're now the host for #{@tt}") do |format|
           format.text
           format.html
         end
  end

  def followup(tea_time_id)
    sendgrid_category "Tea Time Post-Attendance Followup"

    @tea_time = TeaTime.find(tea_time_id)

    unless @tea_time.cancelled?
      as = @tea_time.attendances.group_by(&:status)
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
             subject: 'Hey! Thanks.',
             template_name: template) do |format|
               format.text
               format.html
             end
      end
    end
  end

  def cancellation(tea_time_id, attendance_id)
    sendgrid_category "Tea Time Cancellation Notification"

    @tea_time = TeaTime.find(tea_time_id)
    att = Attendance.find(attendance_id)
    @user = att.user
    mail(to: @user.email, subject: "Sad days — tea time canceled") do |format|
      format.text
      format.html
    end
  end

  def ethos(user_id)
    sendgrid_category "Tea Time Ethos"

    @user = User.find(user_id)
    mail(to: @user.email,
         from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
         subject: "What Tea With Strangers is about",
         template_name: 'registration_followup') do |format|
           format.text
           format.html
         end
  end
end
