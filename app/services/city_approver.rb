class CityApprover
  def initialize(city_id, opts={})
    @city = City.find(city_id)
    @opts = opts
  end

  def approve!
    approval_gate do
      if @city.update(brew_status: "cold_water")
        UserMailer.delay.notify_city_suggestor(@city, :approved)
      end
    end
  end

  def reject!(mail_user: true)
    approval_gate do
      if @city.update(brew_status: "rejected") && mail_user
        UserMailer.delay.notify_city_suggestor(@city, :rejected)
      end
    end
  end

  # This merges the users of the target city into the passed in city
  def merge!(existing_city_id)
    existing = City.find(existing_city_id)
    approval_gate do
      User.where(home_city: @city.id).update_all(home_city_id: existing.id)
      @city.reject!(false)
      UserMailer.delay.notify_city_suggestor(@city, :merged)
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
