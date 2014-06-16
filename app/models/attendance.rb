class Attendance < ActiveRecord::Base
  belongs_to :user
  belongs_to :tea_time, touch: true
  enum :status => [:pending, :flake, :no_show, :present, :waiting_list, :cancelled]
  validates_presence_of :user, :tea_time, presence: true
  validates_uniqueness_of :user_id, scope: :tea_time_id

  before_create :check_capacity

  def todo?
    pending?
  end

  def flake!
    update_attribute(:status, :flake)
  end

  private
    def check_capacity
      if !self.tea_time.spots_remaining?
        return false
      end
    end

end
