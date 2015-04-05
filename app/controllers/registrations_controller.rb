class RegistrationsController < Devise::RegistrationsController
  def create
    if params[:user][:autogen]
      city = City.find(params[:city])

      user_info = GetOrCreateUser.call(user_params, city)

      if user_info[:new_user?] && user_info[:user].valid?
        sign_in user_info[:user]
        message = "You're set! Check your email for your new password."
        if city
          redirect_to schedule_city_path(city), notice: message
        else
          redirect_to root_path, notice: message
        end
      elsif !user_info[:new_user?] && user_info[:user].valid?
        redirect_to new_user_session_path, alert: 'You\'re already registered! Log in using the same email :)'
      else
        redirect_to new_user_registration_path, alert: "We've made a huge mistake."
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

  private

  def user_params
    params[:user].permit(:name, :email, :home_city_id)
  end
end
