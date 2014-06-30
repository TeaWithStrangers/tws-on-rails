class HostsController < ApplicationController
  before_action :authenticate_user!, :authorised?, only: [:new, :create]

  def show
    @city = City.for_code(params[:id])
    @host = User.find(params[:host_id])
    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json { render json: @host }
    end
  end

  def new
    @host = User.new
  end

  def create
    generated_password = Devise.friendly_token.first(8)
    @host = User.new(host_params)
    @host.roles << Role.find_by(name: 'Host')
    @host.password = generated_password
    if @host.save
      [current_user, @host].each do |user|
        UserMailer.user_registration(user, generated_password)
      end
      redirect_to profile_path, message: 'New host unsuccesfully created and emailed!'
    else
      redirect_to new_host_path, message: 'New host not created :/'
    end
  end

  private
    def authorised?
      authorize! :manage, :all
    end

    def host_params
      params.require(:user).permit!
    end
end
