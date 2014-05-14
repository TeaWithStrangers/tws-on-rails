class StaticController < ApplicationController
  def index
    @cities = City.all
    @cities_by_hosts = @cities.group_by { |x| 
      if x.hosts.count == 1
        :single_host
      elsif x.hosts.count > 1
        :many_hosts
      else
        :no_hosts
      end
    }
    pp @cities_by_hosts
  end

  def stories
  end

  def questions
  end

  def hosting
  end
end
