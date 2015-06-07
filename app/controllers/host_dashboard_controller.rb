class HostDashboardController < ApplicationController
  before_action :away_ye_waitlisted
  before_action :check_host
  before_action :use_new_styles

  def show
  end

  # TODO this is here as a temporary step
  # moving away from TeaTime#new to make it clear that this is
  # only a Host action
  def new_tea_time
    host_attributes = [:id, :nickname, :given_name, :family_name]
    @host_thing = User.hosts.select(*host_attributes).collect{ |p| [p.name, p.id] }
    @available_cities = City.all.select(:id, :name).collect{ |p| [p.name, p.id] }

    @tea_time = TeaTime.new(city: current_user.home_city,
                            start_time: Time.now.beginning_of_hour + 1.day,
                            host: current_user)
  end

private
  def check_host
    if !current_user.host?
      # TODO this should go to a page where the CTA is to become a host
      redirect_to profile_path
    end
  end
end