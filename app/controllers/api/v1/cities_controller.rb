class Api::V1::CitiesController < ApplicationController
  def index
    render json: City.all
  end

  def create
    if user_signed_in?
      city              = City.new(params.require(:city).permit(:name))
      city.timezone     = "Pacific Time (US & Canada)" if !city.timezone
      city.city_code    = CityCodeGenerator.generate if !city.city_code
      city.brew_status  = "unapproved"
      if city.save
        render json: city
      else
        render json: city.errors, status: 422
      end
    else
      render json: :unauthenticated, status: 401
    end
  end
end