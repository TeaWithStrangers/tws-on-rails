class Api::V1::CitiesController < ApplicationController
  def index
    render json: City.all
  end
end