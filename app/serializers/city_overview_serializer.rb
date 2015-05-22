class CityOverviewSerializer < ActiveModel::Serializer
  attributes :id, :name, :brew_status, :header_bg, :info, :city_code, :header_bg_small

  def info
    { user_count: object.users_count }
  end

  def header_bg_small
    object.header_bg(:small)
  end
end
