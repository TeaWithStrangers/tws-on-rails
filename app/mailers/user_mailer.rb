class UserMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines

  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

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
end
