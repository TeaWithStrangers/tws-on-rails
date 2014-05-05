class RegistrationsController < Devise::RegistrationsController

  def create
    if params[:user][:autogen]
      generated_password = Devise.friendly_token.first(8)
      user = User.new(name: params[:user][:name], 
                      email: params[:user][:email],
                      password: generated_password)
      if user.save
        UserMailer.user_registration(user, generated_password)
        sign_in(:user, user)
        redirect_to cities_path, message: "All registered! Check your email for your password."
      end
    else
      super
    end
  end
end
