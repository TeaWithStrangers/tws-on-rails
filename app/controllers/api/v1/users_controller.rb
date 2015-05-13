class Api::V1::UsersController < ApplicationController
  def self
    render json: current_user
  end

  def interests
    render json: current_user.tws_interests
  end

  def update_interests
    u = current_user
    u.tws_interests = u.tws_interests.merge(params[:tws_interests])
    u.save
    render json: {success: u.persisted?}
  end
end
