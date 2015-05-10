class CityApprover
  def initialize(city_id)
    @city_id = city_id
  end

  def call
    @city = City.find_by(id: @city_id)
    if @city.nil?
      raise StandardError
    else
      if @city.brew_status == "unapproved"
        @city.update_attributes(brew_status: "cold_water")
      else
        raise "City must be in unapproved state to run this"
      end
    end
  end
end