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
          redirect_to schedule_city_path(city), message: message
        else
          redirect_to root_path, message: message
        end
      end
    else
      super
    end
  end

  def update
    @user = User.find(current_user.id)

    successfully_updated = if needs_password?(@user, params)
      @user.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
    else
      # remove the virtual current_password attribute
      # update_without_password doesn't know how to ignore it
      params[:user].delete(:current_password)
      @user.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
    end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      params[:user][:password].present?
  end
end