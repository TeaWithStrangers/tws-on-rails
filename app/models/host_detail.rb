class HostDetail < ActiveRecord::Base
  belongs_to :user

  ACTIVITY_STATUS_INACTIVE = 0
  ACTIVITY_STATUS_ACTIVE = 1
  ACTIVITY_STATUS_LEGACY = 2
end
