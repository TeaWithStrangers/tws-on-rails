class StaticController < ApplicationController
  def index
    @cities = City.all
    @cities_by_host  = 
      #TODO: I had standards once
      {single_host: [],
       many_hosts: [],
       no_hosts: []}.merge(@cities.group_by { |x| 
         if x.hosts.count == 1 || x.brew_status == :warming_up
           :single_host
         elsif x.hosts.count > 1 || x.brew_status == :fully_brewed
           :many_hosts
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
