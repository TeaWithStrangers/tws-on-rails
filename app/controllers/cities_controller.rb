class CitiesController < ApplicationController
  before_action :set_city, only: [:show, :update, :destroy]

  def index
    @cities = City.all
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @cities }
    end
  end

  def new
    @city = City.new
  end

  def create
    @city = City.create(city_params)
    render json: @city
  end

  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @city }
    end
  end

  def update
    @city.update!(city_params)
    render json: @city
  end 

  def destroy
    if city.destroy
      redirect_to cities_index
    elsif
      redirect_to root_path
    end
  end

  private
    def city_params
      params.permit(:name, :city_code, :description, :tagline)
    end

    def set_city
      @city = (City.for_code(params[:id]) || City.find(params[:id]))
    end
end
