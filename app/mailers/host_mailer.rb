class HostMailer < ActionMailer::Base
  default from: "\"The Robots at Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def pre_tea_time_nudge(tea_time_id)
    @tea_time = TeaTime.find_by(id: tea_time_id)
    @shareable_num_string = @tea_time.attendees_with_shareable_phone_numbers.map do |u|
      "#{u.name} (#{u.phone_number})"
    end.join(", ")

    mail(to: @tea_time.host.email) do |format|
      format.text
      format.html
    end
  end
end
