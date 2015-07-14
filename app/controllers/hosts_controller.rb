class HostsController < ApplicationController
  before_action :authenticate_user!, :authorised?, only: [:new, :create]
  before_action :use_new_styles, except: [:new, :create]

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

    @host = User.find_or_initialize_by(email: host_params[:email])
    user_exists = @host.persisted?
    @host.assign_attributes(host_params)
    @host.roles << :host

    if !user_exists
      @host.password = generated_password
    end

    if @host.save
      UserMailer.delay.host_registration(@host, user_exists ? nil : generated_password)
      redirect_to profile_path, notice: 'New host successfully created and emailed!'
    else
      redirect_to new_host_path, alert: 'New host not created :/'
    end
  end

  def update
    @user = User.find(current_user.id)
    if @user && current_user == @user
      if @user.update_attributes(update_params)
        redirect_to host_profile_path
      else
        render "host_profile_path"
      end
    else
      redirect_to profile_path(current_user), alert: "Sorry, you can't edit other people's profiles. Duh"
    end
  end

private
  def update_params
    params.require(:user).permit(:summary, :story, :tagline, :twitter, :topics)
  end

  def authorised?
    authorize! :manage, :all
  end

  def host_params
    params.require(:user).permit!
  end
end
