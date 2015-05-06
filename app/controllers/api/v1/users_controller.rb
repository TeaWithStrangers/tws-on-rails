class Api::V1::UsersController < ApplicationController
  def self
    render json: current_user
  end
end
