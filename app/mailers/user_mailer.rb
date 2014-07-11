class UserMailer < ActionMailer::Base
  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def registration(user, password)
    @user = user; @password=password;
    template = @user.home_city.tea_times.future_until(2.weeks.from_now).blank? ? 
      'registration_no_tea' : 'registration'
    mail(from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
         to: @user.email, 
         subject: 'High fives from Tea With Strangers!',
         template_name: template).deliver!
  end
end
