class UserMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines

  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def registration(user, token)
    sendgrid_category "User Registration"

    @user = user; @token = token;

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

  def host_registration(user, password)
    sendgrid_category "Host Registration"

    @user = User.find(user)
    @password = password

    mail(from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
         to: @user.email,
         subject: "Welcome to The Family") do |format|
           format.text
           format.html
         end
  end
end
