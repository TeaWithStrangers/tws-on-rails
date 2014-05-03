class Role < ActiveRecord::Base
  VALID_ROLES = %w{Admin User Host}
  has_and_belongs_to_many :users 
  validates :name, inclusion: {in: VALID_ROLES}
end
