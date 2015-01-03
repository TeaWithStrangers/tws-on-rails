class StaticController < ApplicationController
  def index
    @cities = City.visible
    @cities_by_host  = Hash.new([]).merge(
      @cities.group_by { |x|
         if (x.fully_brewed? || x.hosts.count > 1)
           :many_hosts
         elsif (x.warming_up? || x.hosts.count == 1)
           :single_host
         else
           :no_hosts
         end
       })
  end

  def stories
  end

  def questions
  end

  def hosting
  end
end
