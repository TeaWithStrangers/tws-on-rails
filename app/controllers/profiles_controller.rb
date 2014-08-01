class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @hosting = current_user.tea_times.future
    @attending = current_user.attendances_for(TeaTime.future)
  end

  def history
    @hosting = current_user.tea_times.order("start_time desc")
    @attending = Attendance.attended.where(user: current_user).joins(:tea_time).order('tea_times.start_time desc')
  end
end
