class UserMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines

  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def confirm_city_suggestion(city_id)
    @city = City.find(city_id)
    @user = @city.suggested_by_user

    mail(to: @user.email, subject: "We got your suggestion for Tea With Strangers in #{@city.name}") do |format|
      format.text { render }
      format.html { render }
    end
  end

  def notify_city_suggestor(city_id, admin_action)
    @city = City.find(city_id)
    @user = @city.suggested_by_user
    cancel_delivery if @user.nil?

    @partial = "city_suggestion_#{admin_action}"

    case admin_action
    when :approved
      subject = "Thanks for suggesting #{@city.name}, #{@user.name}!"
    when :rejected
      subject = "About #{@city.name}, #{@user.name}"
    when :merged
      subject = "Thanks for suggesting #{@city.name}, #{@user.name}..."
    end

    mail(to: @user.email, subject: subject) do |format|
      format.text { render }
      format.html { render }
    end
  end

  # TODO this should replace registration
  def new_registration(user)
    @user = user;

    mail(from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
         to: @user.email,
         subject: "Thanks for being awesome, #{@user.nickname}!") do |format|
           format.text
           format.html
         end
  end

  def registration(user, password)
    sendgrid_category "User Registration"

    @user = user; @password = password;

    # We send a different mail if the user has registered for a tea time
    template = @user.home_city.tea_times.future_until(2.weeks.from_now).empty? ?
      'registration_no_tea' : 'registration'

    mail(from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
         to: @user.email,
         subject: "Thanks for being awesome, #{@user.name}!") do |format|
           format.text { render template }
           format.html { render template }
         end
  end

  def waitlisted_registration(user)
    @user = user;

    mail(from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
         to: @user.email,
         subject: "Thanks for being awesome #{@user.nickname}") do |format|
           format.text
           format.html
         end
  end

  def host_registration(user, password)
    sendgrid_category "Host Registration"

    @user = User.find(user)
    @password = password

    mail(from: "\"The Robots at Tea With Strangers\" <sayhi@teawithstrangers.com>",
         to: @user.email,
         subject: "Welcome to The Family") do |format|
           format.text
           format.html
         end
  end
end
