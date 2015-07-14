class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_filter :away_ye_waitlisted
  before_action :use_new_styles

  def show
    @hosting = current_user.tea_times.future.order("start_time ASC")
    @attending = current_user.attendances_for(TeaTime.future).attended.joins(:tea_time).order('tea_times.start_time ASC')
    @waitlist = current_user.attendances_for(TeaTime.future).waiting_list.joins(:tea_time).order('tea_times.start_time ASC')
  end

  def host_tasks
    @tasks = current_user.tea_times.where(followup_status: [0, 1]).past.order("start_time DESC")
  end

  def history
    @hosted = current_user.tea_times.past.order("start_time DESC")
    @attended = current_user.attendances_for(TeaTime.past).attended.joins(:tea_time).order('tea_times.start_time DESC')
    @hosting = current_user.tea_times.future.order("start_time ASC")
    @attending = current_user.attendances_for(TeaTime.future).attended.joins(:tea_time).order('tea_times.start_time ASC')
  end

  def host_profile
  end

  def update_host_profile
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
    params.require(:user).permit(:summary, :story, :tagline, :twitter)
  end
end
