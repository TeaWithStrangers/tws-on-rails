class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @hosting = current_user.tea_times.future.order("start_time DESC")
    @attending = current_user.attendances_for(TeaTime.future).attended.joins(:tea_time).order('tea_times.start_time DESC')
    @waitlist = current_user.attendances_for(TeaTime.future).waiting_list.joins(:tea_time).order('tea_times.start_time DESC')
  end

  def host_tasks
    @pending = current_user.tea_times.where(followup_status: TeaTime.followup_statuses[:pending])
    @notes = current_user.tea_times.where(followup_status: TeaTime.followup_statuses[:marked_attendance])
  end

  def history
    @hosting = current_user.tea_times.past.order("start_time DESC")
    @attending = current_user.attendances_for(TeaTime.past).attended.joins(:tea_time).order('tea_times.start_time DESC')
  end
end
