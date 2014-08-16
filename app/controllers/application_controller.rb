class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :null_session
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def with_timezone(zone, &block)
    Time.use_zone(zone, &block)
  end

  rescue_from CanCan::AccessDenied do |exception|
    go_back(exception)
  end

  protected

    def go_back(exception)
      begin
        redirect_to :back, :alert => exception.message
      rescue ActionController::RedirectBackError
        redirect_to root_path
      end
    end

    def configure_permitted_parameters
      permitted = [:name, :email, :password, :password_confirmation, :avatar,
                   :current_password, :autogen, :tagline, :summary, :topics,
                   :story, :home_city_id, :facebook, :twitter]
      [:sign_up, :account_update].each do |s|
        devise_parameter_sanitizer.for(s) do |u|
          u.permit(*permitted)
        end
      end
    end

end
