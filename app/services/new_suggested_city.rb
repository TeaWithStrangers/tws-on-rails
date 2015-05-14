class NewSuggestedCity
  # Returns a hash with keys :user and :new_user?
  # :user => User, :new_user? => Boolean
  def self.call(params, user=nil)
    city = City.new(params)
    city.city_code = CityCodeGenerator.generate
    city.timezone = "Pacific Time (US & Canada)"
    city.brew_status = "unapproved"
    if city.save && user
      city.update(suggested_by_user: user)
      user.update(home_city: city) if user.home_city.nil?
    end

    city
  end
end
