class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_filter :away_ye_waitlisted
  before_action :use_new_styles

  def show
    @attending = current_user.attendances_for(TeaTime.future).attended.joins(:tea_time).order('tea_times.start_time ASC')
    @waitlist = current_user.attendances_for(TeaTime.future).waiting_list.joins(:tea_time).order('tea_times.start_time ASC')
  end

  def host_tasks
    @tasks = current_user.tea_times.where(followup_status: [0, 1]).past.order("start_time DESC")
  end

  def history
    @hosting = current_user.tea_times.past.order("start_time DESC")
    @attending = current_user.attendances_for(TeaTime.past).attended.joins(:tea_time).order('tea_times.start_time DESC')
  end
end
