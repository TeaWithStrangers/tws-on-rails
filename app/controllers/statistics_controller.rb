class StatisticsController < ActiveRecord::BaseController
  respond_to :json

  def active_hosts
    cities = City.all.order('id')

    @statistics = []

    cities.each { |city|

      @hosts = city.hosts
      @active_hosts = []
      @hosts.each { |host|
        if host.tea_times.where(:start_time => (Time.now.end_of_week - 2.weeks)..Time.now.end_of_week).count
          @active_hosts << host
        end
      }

      @statistics << {
        'stat' => "#{city.name}",
        'value' => sprintf("%0.0f%", ((@active_hosts.count == 0 or @hosts.count == 0) ? 0 : (@active_hosts.count.to_f / @hosts.count)*100))
      }
    }

    render @statistics
  end

  def hosts_by_city
    @data = []

    @cities = City.all.order('id').all
    
    @cities.map {|city|
      @data << {
        'label' => city.name,
        'value' => city.hosts.count
      }
    }

    @data.each_with_index { |item, index|
      item.merge! @@graph_color_map[index]
      @data[index] = item
    }

    apiResponse = {'response' => @data}

    render apiResponse
  end

  def teatimes_by_city
    @data = []

    @cities = City.all.order('id').all
    
    @cities.map {|city|
      @data << {
        'label' => city.name,
        'value' => city.tea_times.count
      }
    }

    @data.each_with_index { |item, index|
      item.merge! @@graph_color_map[index]
      @data[index] = item
    }

    apiResponse = {'response' => @data}

    render apiResponse
  end
