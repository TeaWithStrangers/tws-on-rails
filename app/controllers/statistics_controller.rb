class StatisticsController < ApplicationController
  respond_to :json

  def active_hosts
    data = City.all.map do |city|
      hosts = city.hosts
      active_hosts = []
      hosts.each do |host|
        if host.tea_times.before(Time.now.end_of_week).after(Time.now.end_of_week - 2.weeks).count > 0
          active_hosts << host
        end
      end

      {
        active_hosts: active_hosts.map {|u| u.as_json(only: [:name, :id]) },
        inactive_hosts: (hosts - active_hosts).map {|u| u.as_json(only: [:name, :id]) },
        active_hosts_count: active_hosts.count,
        total_host_count: hosts.count,
        city: city_serializer(city)
      }
    end
    render json: data, root: false
  end

  def hosts_by_city
    #TODO: Once we merge in user role bitmasks we can simplify this into a
    #single query that just joins cities and users together on home_city_id
    #where user_roles & x > 0 
    data = User.hosts.group(:home_city_id).count.map { |city_id, count| 
      {
        city: city_serializer(City.find(city_id)),
        total_host_count: count 
      } 
    }

    render json: data, root: false
  end

  def teatimes_by_city
    records = City.select('cities.name, cities.id, count(*)').
      joins('inner join tea_times on
            tea_times.city_id=cities.id').
      group('cities.name, cities.id order by count(tea_times.id) desc')
    data = records.map { |c| {city: city_serializer(c) , count: c.count } }
    render json: data, root: false
  end
  
  private
  def city_serializer(city)
    city.as_json(only: [:name, :id])
  end
end
