class TeaTime < ActiveRecord::Base
  belongs_to :city
  enum followup_status: [:na, :pending, :sent]
end
