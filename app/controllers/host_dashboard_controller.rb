class HostDashboardController < ApplicationController
  before_action :check_host
  before_action :use_new_styles

  def show

  end

private
  def check_host
    if !current_user.host?
      # TODO this should go to a page where the CTA is to become a host
      redirect_to profile_path
    end
  end
end