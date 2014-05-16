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

  def update
    account_update_params = devise_parameter_sanitizer.sanitize(:account_update)
    # required for settings form to submit when password is left blank
    if account_update_params[:current_password].blank?
      account_update_params.delete("current_password")
      account_update_params.delete("password")
      account_update_params.delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(account_update_params)
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end 
end
