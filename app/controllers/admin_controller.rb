class AdminController < ApplicationController
  before_action :authenticate_user!, :authorized?

  def find
  end

  def overview
  end

  def users
  end

  def write_mail
  end
  
  #TODO Test and reject invalid inputs
  def send_mail
    MassMailer.delay.simple_mail(params)
    redirect_to action: :write_mail, flash: "Succesfully sent mail"
  end


  def ghost
    user = User.find_by(email: params[:email])
    if user
      sign_in(:user, user)
      redirect_to profile_path
    else
      redirect_to :back
    end
  end

  private
    def authorized?
      unless current_user.admin?
        redirect_to root_url, :notify => "You're not allowed in here!"
      end
    end
end
