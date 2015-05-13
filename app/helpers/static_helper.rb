module StaticHelper
  def next_step_path
    if current_user.nil?
      sign_up_path
    elsif current_user.home_city.nil?
      cities_path
    else
      forbes_city_path(current_user.home_city)
    end
  end
end
