class Api::V1::AboutController < ApplicationController
  def show
    render json: {
      about: {
        name: "TWS::API",
        current_sha: `cd #{Rails.root}; git rev-parse HEAD`
      }
    }
  end
end