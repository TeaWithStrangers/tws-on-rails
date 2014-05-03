class ProfilesController < ApplicationController
  before_action :set_and_authorize_user

  def show
  end

  def flake
    tt = TeaTime.find(params[:tea_time])
    at = Attendance.find_by(tea_time_id: tt, user_id: @user)
    if at.flake!
      redirect_to action: :show, message: "You flaked! Maybe next time?", status: 204
    end
  end

  private
  def set_and_authorize_user
    if params[:id]
      @user = User.find(params[:id])
    else
      @user = User.find(current_user)
    end
    authorize! :read, @user
  end
end
