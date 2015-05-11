class CityApprover
  def initialize(city_id, opts={})
    @city = City.find(city_id)
    @opts = opts
  end

  def approve!
    approval_gate do
      if @city.update_attributes(brew_status: "cold_water")
        UserMailer.notify_city_suggestor_of_approval(@city).deliver
      end
    end
  end

  private
    def approval_gate
      if @city.unapproved?
        yield
      else
        raise CityApprovedError.new("#{@city.name} - ID: #{@city.id} is already approved:
        #{@city.brew_status}")
      end
    end

  class CityApprovedError < StandardError; end
end
