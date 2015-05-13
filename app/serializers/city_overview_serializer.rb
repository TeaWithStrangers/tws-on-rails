class CityOverviewSerializer < ActiveModel::Serializer
  attributes :id, :name, :brew_status, :header_bg, :info, :city_code

  def info
    { user_count: object.users.count }
  end
end
