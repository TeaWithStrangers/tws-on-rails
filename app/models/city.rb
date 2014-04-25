class City < ActiveRecord::Base
  validates_uniqueness_of :city_code
  enum brew_status: [ :cold_water, :warming_up, :fully_brewed ]
  has_many :tea_times
end
