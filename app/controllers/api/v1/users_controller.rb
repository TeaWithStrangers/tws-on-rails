class Api::V1::UsersController < ApplicationController
  before_filter :authenticate_api

  def self
    render json: current_user
  end

  def interests
    render json: current_user.tws_interests
  end

  def update_interests
    u = current_user
    u.tws_interests = u.tws_interests.merge(booleanized_params(params[:tws_interests]))
    u.save
    render json: {success: u.persisted?}
  end

  def authenticate_api
    unless current_user
      head :no_content
    end
  end

  private

  # This method turns a hash that looks like e.g. `{"key1" => "true", "key2" => "false"}` into
  # `{"key1" => true, "key2" => false}`
  # Rails 4.2 will have a better way to do this, see http://stackoverflow.com/a/19423406
  def booleanized_params(hash)
    Hash[ hash.map {|k,v| [k, v == true || v == "true"]} ]
  end
end
