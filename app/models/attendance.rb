class Attendance < ActiveRecord::Base
  belongs_to :user
  belongs_to :tea_time, touch: true
  enum :status => [:pending, :flake, :no_show, :present, :waiting_list, :cancelled]
  validates_presence_of :user, :tea_time, presence: true
  validates_uniqueness_of :user_id, scope: :tea_time_id

  before_create :check_capacity
  after_create :queue_reminder_mails, :queue_ethos_mails

  def todo?
    pending?
  end

  def flake!
    update_attribute(:status, :flake)
    AttendanceMailer.delay.flake(self.id)
  end

  def queue_ethos_mails
    TeaTimeMailer.delay(run_at: Time.now + 1.hour).ethos(self.user.id)
  end

  def queue_reminder_mails
    st = self.tea_time.start_time
    AttendanceMailer.delay(run_at: st - 2.days).reminder(self.id, :two_day)
    AttendanceMailer.delay(run_at: st - 12.hours).reminder(self.id, :same_day)
  end


  private
    def check_capacity
      if !self.tea_time.spots_remaining?
        return false
      end
    end

end
