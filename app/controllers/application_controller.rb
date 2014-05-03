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

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit :name, :email, :password, :password_confirmation
      end
    end

end
