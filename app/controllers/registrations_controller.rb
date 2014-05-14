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
        message = "All registered! Check your email for your password."
        if params[:city]
          redirect_to City.find(params[:city]), message: message
        else
          redirect_to root_path, message: message
        end
      end
    else
      super
    end
  end
end
