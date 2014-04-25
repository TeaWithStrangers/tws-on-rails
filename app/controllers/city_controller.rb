class CityController < ApplicationController
  before_filter :upcase_city_id, :except => [:index, :create]

  def index
    @cities = City.all
    render json: @cities
  end

  def create
    @city = City.create(city_params)
    render json: @city
  end

  def show
    @city = City.find_by!(city_code: params[:id])
    render json: @city
  end

  def update
    @city = City.find_by!(city_code: params[:id])
    @city.update!(city_params)
    render json: @city
  end 

  def destroy
    @city = City.find_by!(city_code: params[:id])
    city.destroy
    render status: 204
  end

  private
    def city_params
      params.permit(:name, :city_code, :description, :tagline)
    end

    def upcase_city_id
      params[:id].upcase!
    end
end
