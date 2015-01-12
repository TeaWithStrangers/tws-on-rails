class StaticController < ApplicationController
  def index
    @cities = City.visible
    @cities_by_host  = Hash.new([]).merge(
      @cities.group_by { |x|
        if (x.fully_brewed? || x.warming_up?)
          :hosts
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
