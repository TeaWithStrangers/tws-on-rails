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

  def host_drip(latest_tea_time_id, drip_index = nil)
    @tt = TeaTime.find_by_id(latest_tea_time_id)
    cancel_delivery unless @tt
    @host = @tt.host
    @drip_index = drip_index
    cancel_delivery unless @host.commitment_overview == HostDetail::REGULAR_COMMITMENT

    subject = case drip_index
    when 0
      "Your next tea time"
    when 1
      "Hi there"
    when 2
      "Moving oolong 🍵"
    else
      "🤗: Knock knock! 🤔: Who’s there?"
    end

    mail(to: @host.email,
         subject: subject) do |format|
      format.text
      format.html
    end
  end

  def host_drip_reminder(latest_tea_time_id, drip_index)
    @tt = TeaTime.find_by_id(latest_tea_time_id)
    cancel_delivery unless @tt
    @host = @tt.host
    @drip_index = drip_index
    cancel_delivery unless @host.commitment_overview == HostDetail::REGULAR_COMMITMENT

    subject = case drip_index
    when 0
      "Your next tea time"
    when 2
      "Moving oolong 🍵"
    end

    mail(to: @host.email,
         subject: subject) do |format|
      format.text
      format.html
    end
  end

  def no_commitment_drip(latest_tea_time_id, drip_index = nil)
    @tt = TeaTime.find_by_id(latest_tea_time_id)
    cancel_delivery unless @tt
    @host = @tt.host
    cancel_delivery unless @host.commitment_overview == HostDetail::NO_COMMITMENT
    @drip_index = drip_index

    subject = case drip_index
    when 0
      "Thinking about ya"
    else
      "It’s been a while!"
    end

    mail(to: @host.email,
         subject: subject) do |format|
      format.text
      format.html
    end
  end

  def no_commitment_drip_reminder(host_id)
    @host = User.find_by_id(host_id)
    cancel_delivery unless @host
    cancel_delivery unless @host.commitment_overview == HostDetail::NO_COMMITMENT

    mail(to: @host.email,
         subject: "Thinking about ya") do |format|
      format.text
      format.html
    end
  end

  def pause(host_id)
    @host = User.find_by_id(host_id)
    cancel_delivery unless @host
    cancel_delivery unless @host.commitment_overview == HostDetail::INACTIVE_COMMITMENT

    mail(to: @host.email,
         subject: "We just heard the news…") do |format|
      format.text
      format.html
    end
  end

  def inactive_host_posted(host_id)
    @host = User.find_by_id(host_id)
    cancel_delivery unless @host
    cancel_delivery unless @host.commitment_overview == HostDetail::INACTIVE_COMMITMENT
    cancel_delivery unless @host.tea_times.future.pending.any?

    mail(to: @host.email,
         subject: "Hello again!") do |format|
      format.text
      format.html
    end
  end

  def commitment_intro(host_id)
    @host = User.find_by_id(host_id)
    cancel_delivery unless @host
    cancel_delivery if @host.commitment_overview == HostDetail::INACTIVE_COMMITMENT
     
    mail(to: @host.email,
         subject: "Sweet! Here’s how this works") do |format|
      format.text
      format.html
    end
  end
end
