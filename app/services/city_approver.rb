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
        if @city.update_attributes(brew_status: "cold_water")
          UserMailer.notify_city_suggestor_of_approval(@city).deliver
        end
      else
        raise "City must be in unapproved state to run this"
      end
    end
  end
end