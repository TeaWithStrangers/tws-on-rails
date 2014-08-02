class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @hosting = current_user.tea_times.future
    @attending = current_user.attendances_for(TeaTime.future)
  end

  def history
    @hosting = current_user.tea_times.past
    @attending = current_user.attendances.past
  end
end
