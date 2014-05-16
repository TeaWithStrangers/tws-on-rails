class RegistrationsController < Devise::RegistrationsController
  def create
    city = City.find_by(id: params[:city])
    if params[:user][:autogen]
      generated_password = Devise.friendly_token.first(8)
      user = User.new(name: params[:user][:name], 
                      email: params[:user][:email],
                      password: generated_password,
                      home_city: city)
      if user.save
        UserMailer.user_registration(user, generated_password)
        sign_in(:user, user)
        message = "All registered! Check your email for your password."
        if city
          redirect_to city, message: message
        else
          redirect_to root_path, message: message
        end
      end
    else
      super
    end
  end
end
