class Attendance < ActiveRecord::Base
  belongs_to :user
  belongs_to :tea_time, touch: true
  enum :status => [:pending, :flake, :no_show, :present, :waiting_list, :cancelled]
  validates_presence_of :user, :tea_time, presence: true
  validates_uniqueness_of :user_id, scope: :tea_time_id

  scope :attended, ->() { where(status: [:cancelled, :pending, :present].map {|x| Attendance.statuses[x]}) }
  scope :waitlisted, ->() { where(status: [:waiting_list].map {|x| Attendance.statuses[x]}) }

  def todo?
    pending?
  end

  def user
    super || User.nil_user
  end

  def flake!(opts = {})
    unless flake?
      if !tea_time.spots_remaining?
        tea_time.send_waitlist_notifications
      end
      update_attribute(:status, :flake)
      AttendanceMailer.delay.flake(self.id) if !(opts[:email] == false)
    end
  end

  def queue_mails
    if self.pending?
      #Immediate Attendance Confirmation
      AttendanceMailer.delay.registration(self.id)
      #Ethos Email
      TeaTimeMailer.delay(run_at: Time.now + 1.hour).ethos(self.user.id)
      st = self.tea_time.start_time
      AttendanceMailer.delay(run_at: st - 2.days).reminder(self.id, :two_day)
      AttendanceMailer.delay(run_at: st - 12.hours).reminder(self.id, :same_day)
    elsif self.waiting_list?
      AttendanceMailer.delay.waitlist(self.id)
    end
  end

  def occurred?
    tea_time.occurred?
  end

  def try_join
    if self.tea_time.spots_remaining?
      self.status = :pending
    else
      self.status = :waiting_list
    end
  end
end
