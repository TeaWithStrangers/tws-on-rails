class RegistrationsController < Devise::RegistrationsController
  def create
    if params[:user][:autogen]
      error_message = validate_new_user_input(params)
      if(error_message.to_s != '')
        redirect_to :back, alert: error_message
        return
      end
      city = City.find(params[:city])
      user_info = GetOrCreateUser.call(params[:user], city)
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

  def validate_new_user_input(params)
    if(params[:city].to_s == '')
      error_message = 'Hey! You forgot to select a city.'
    elsif(params[:user][:email].to_s == '')
      error_message = 'Please enter your email.'
    elsif(params[:user][:name].to_s == '')
      error_message = 'What\'s your name?'
    end

  end

  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      params[:user][:password].present?
  end
end
