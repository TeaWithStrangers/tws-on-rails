class Attendance < ActiveRecord::Base
  belongs_to :user
  belongs_to :tea_time, touch: true
  enum :status => [:pending, :flake, :no_show, :present, :waiting_list, :cancelled]
  validates_presence_of :user, :tea_time, presence: true
  validates_uniqueness_of :user_id, scope: :tea_time_id
  validate :host_is_not_own_attendee

  scope :attended, ->() { where(status: [:cancelled, :pending, :present].map {|x| Attendance.statuses[x]}) }
  scope :present_or_pending, ->() { where(status: [:pending, :present].map {|x| Attendance.statuses[x]}) }
  scope :waitlisted,    ->() { where(status: [:waiting_list].map {|x| Attendance.statuses[x]}) }

  scope :pending,       ->() { where(status: [:pending].map {|x| Attendance.statuses[x]})  }
  scope :present,       ->() { where(status: [:present].map {|x| Attendance.statuses[x]})  }
  scope :flake,         ->() { where(status: [:flake].map   {|x| Attendance.statuses[x]})  }
  scope :no_show,       ->() { where(status: [:no_show].map {|x| Attendance.statuses[x]})  }

  delegate :start_time, to: :tea_time, prefix: true

  # After attendance is updated, update the user tea time details in the SendGrid list
  after_create { SendGridList.sync_user(self.user) }
  after_update { SendGridList.sync_user(self.user) }

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
      assign_attributes({
        status: :flake,
        reason: opts[:reason]
      })
      save!
      AttendanceMailer.delay.flake(self.id) if !(opts[:email] == false)
    end
  end

  def send_confirmation_mail
    AttendanceMailer.delay.registration(self.id)
  end

  def send_waitlist_mail
    AttendanceMailer.delay.waitlist(self.id)
  end

  # TODO why is this run specifically 1 hour after creating attendance?
  def send_ethos_mail
    TeaTimeMailer.delay(run_at: Time.now + 1.hour).ethos(self.user_id)
  end

  def occurred?
    tea_time.occurred?
  end

  def host_is_not_own_attendee
    if user == tea_time.host
      errors.add(:user, "host can't attend their own tea time")
    end
  end

  class << self
    def host_statuses
      self.statuses.keys - ['waiting_list', 'cancelled', 'pending']
    end
  end
end
