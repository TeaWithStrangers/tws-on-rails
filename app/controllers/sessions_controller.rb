class SessionsController < Devise::SessionsController
  def new
    @use_new_styles = true
    return redirect_to profile_path if current_user

    # If the redirect_to_tt parameter exists, store the URL
    # to redirect to after signup
    # See https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
    if params[:redirect_to_tt] && TeaTime.find(params[:redirect_to_tt])
      store_location_for(:user, '/tea_times/' + params[:redirect_to_tt].to_i.to_s)
    end

    super
  end
end