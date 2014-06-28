class TeaTimeMailer < ActionMailer::Base
  default from: "\"Tea With Strangers\" <sayhi@teawithstrangers.com>"

  def user_registration(user, password)
    @user = user; @password=password;
    mail(from: "\"Ankit at Tea With Strangers\" <ankit@teawithstrangers.com>",
         to: @user.email, 
         subject: 'High fives from Tea With Strangers!').
         deliver!
  end
end
