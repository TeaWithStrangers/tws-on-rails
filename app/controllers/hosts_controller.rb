class HostsController < ApplicationController
  def show
    @city = City.for_code(params[:id])
    @host = Host.find(params[:host_id])
  end

  def create
    @host = User.build
    @host.roles << Roles.find(name: :host)
    @host
  end
end
