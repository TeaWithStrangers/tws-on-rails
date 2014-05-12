class HostsController < ApplicationController
  def show
  end

  def create
    @host = User.build
    @host.roles << Roles.find(name: :host)
    @host
  end
end
