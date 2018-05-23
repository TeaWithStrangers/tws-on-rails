class RegistrationsController < Devise::RegistrationsController
  before_action :use_new_styles, only: [:update, :edit]
  def create
    if params[:referral] == false
      super
    else
      user_info = GetOrCreateNonWaitlistedUser.call(user_params)
      if user_info[:new_user?] && user_info[:user].valid?
        sign_in user_info[:user]

        # Retrieve redirect location from Devise if exists
        redirect_url = stored_location_for(User)

        # Fall back to tea times path if no redirect location exists
        unless redirect_url
          redirect_url = tea_times_path
        end

        # If the ?remind_next_month GET param exists, show banner
        if params.has_key?(:remind_next_month)
          flash[:success] = "We'll let you know about tea times next month!"
        end

        redirect_to redirect_url
      elsif !user_info[:new_user?] && user_info[:user].valid?
        redirect_to new_user_session_path, alert: 'You\'ve made an account already. Log in using the same email. Click \'Forgot Password\' if you\'re confused.'
      else
        redirect_to sign_up_path, alert: "We've made a mistake!"
      end
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
      bypass_sign_in @user
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  def edit
    @hosting = current_user.tea_times.future.order("start_time ASC")
  end

  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      params[:user][:password].present?
  end

  private
    def after_update_path_for(resource)
      profile_path
    end

    def user_params
      a = params.require(:user).permit(:nickname, :email, :password, :phone_number, :home_city_id)
      a[:given_name] = a[:nickname] if !a[:given_name]
      a
    end
end
