class UserSerializer < ActiveModel::Serializer
  attributes :id, :nickname, :family_name, :given_name, :home_city_id
end
