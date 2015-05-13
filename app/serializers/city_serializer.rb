class CitySerializer < ActiveModel::Serializer
  attributes :id, :name, :city_code, :timezone, :tagline, :brew_status, :description, :header_bg
end
