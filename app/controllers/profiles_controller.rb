class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @hosting = current_user.tea_times.future
    @attending = current_user.attendances_for(TeaTime.future)
  end

  def history
    @hosting = current_user.tea_times.past.order("start_time DESC")
    @attending = current_user.attendances_for(TeaTime.past).attended.joins(:tea_time).order('tea_times.start_time DESC')
  end
end
