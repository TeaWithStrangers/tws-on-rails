class CitySuggestionsController < ApplicationController
  def new
    use_new_styles
    if current_user
      @city = City.new
    else
      flash[:notice] = 'Sign up first so we can let you know when your city is approved!'
      redirect_to sign_up_path
    end
  end

  def create
    use_new_styles
    @city = NewSuggestedCity.call(city_params, current_user)
    if @city.persisted?
      redirect_to forbes_city_path(@city), notice: 'We\'ve gotten your submission and will get to it ASAP.'
    else
      render :new, alert: "Something went wrong! Our fault. Could you try again?"
    end
  end

private
  def city_params
    params.require(:city).permit!
  end
end