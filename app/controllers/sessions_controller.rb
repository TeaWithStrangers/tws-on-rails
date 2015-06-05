class SessionsController < Devise::SessionsController
  def new
    @use_new_styles = true
    return redirect_to profile_path if current_user
    super
  end
end