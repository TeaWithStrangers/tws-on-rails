class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :null_session
  before_filter :default_format_json
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def default_format_json
    if(request.headers["HTTP_ACCEPT"].nil? &&
       params[:format].nil?)
      request.format = "json"
    end
  end

  def with_timezone(zone, &block)
    Time.use_zone(zone, &block)
  end

  protected

    def configure_permitted_parameters
      permitted = [:name, :email, :password, :password_confirmation, :avatar,
                   :current_password, :autogen, :tagline, :summary, :topics,
                   :story, :home_city_id]
      [:sign_up, :account_update].each do |s|
        devise_parameter_sanitizer.for(s) do |u|
          u.permit(*permitted)
        end
      end
    end

end
