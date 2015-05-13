class CitySerializer < ActiveModel::Serializer
  attributes :id, :name, :city_code, :timezone, :tagline, :brew_status, :description, :header_bg

  def city_code
    object.city_code.downcase if object.city_code
  end
end
