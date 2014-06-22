class StaticController < ApplicationController
  def index
    @cities = City.visible
    @cities_by_host  = 
      #TODO: I had standards once
      {single_host: [],
       many_hosts: [],
       no_hosts: []}.merge(@cities.group_by { |x| 
         if (x.hosts.count > 1 || x.fully_brewed?)
           :many_hosts
         elsif (x.hosts.count == 1 || x.warming_up?)
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
