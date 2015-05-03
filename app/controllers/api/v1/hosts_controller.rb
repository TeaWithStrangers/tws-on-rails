class Api::V1::HostsController < ApplicationController

  # /api/v1/hosts
  def index
    # TODO this is a stopgap. It returns exactly what the UI wants
    # so we don't have to build associations and make multiple
    # requests for the /admin/overview/hosts page.
    # When the client side becomes a little more mature, we should
    # be make this endpoint a little less terrible and only serve host info
    host_json = User.hosts.map do |user|
      {
        name:                user.name,
        number_of_teatimes:  user.tea_times.count,
        last_teatime:        user.tea_times.past.last,
        next_teatime:        user.tea_times.future.last,
        total_attendees:     user.tea_times.map {|t| t.attendances.count}.inject(0, &:+),
      }
    end

    render json: {hosts: host_json }
  end
end
