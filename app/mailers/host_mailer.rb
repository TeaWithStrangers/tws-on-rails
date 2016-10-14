class HostMailer < ActionMailer::Base
  default from: "\"Tea With Strangers Robots\" <sayhi@teawithstrangers.com>"

  def pre_tea_time_nudge(tea_time_id)
    @tea_time = TeaTime.find_by(id: tea_time_id)
    cancel_delivery if @tea_time.cancelled?

    @shareable_num_string = @tea_time.attendees_with_shareable_phone_numbers.map do |u|
      "#{u.name} (#{u.phone_number})"
    end.join(", ")

    mail(to: @tea_time.host.email,
         subject: "Remind your attendees about tea time!") do |format|
      format.text
      format.html
    end
  end
end
