class Attendance < ActiveRecord::Base
  # Attendances should never be deleted, only soft-deleted
  acts_as_paranoid

  belongs_to :user
  belongs_to :tea_time, touch: true
  enum :status => [:pending, :flake, :no_show, :present, :waiting_list, :cancelled]
  validates_presence_of :user, :tea_time, presence: true
  validates_uniqueness_of :user_id, scope: :tea_time_id

  scope :attended, ->() { where(status: [:cancelled, :pending, :present].map {|x| Attendance.statuses[x]}) }
  scope :waitlisted,    ->() { where(status: [:waiting_list].map {|x| Attendance.statuses[x]}) }

  scope :pending,       ->() { where(status: [:pending].map {|x| Attendance.statuses[x]})  }
  scope :present,       ->() { where(status: [:present].map {|x| Attendance.statuses[x]})  }
  scope :flake,         ->() { where(status: [:flake].map   {|x| Attendance.statuses[x]})  }
  scope :no_show,       ->() { where(status: [:no_show].map {|x| Attendance.statuses[x]})  }

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

  def send_mail
    if self.pending?
      #Immediate Attendance Confirmation
      AttendanceMailer.delay.registration(self.id)

      queue_reminders

      #Ethos Email is sent when a user has never attended a tea time before
      if user.attendances.present.count.zero?
        TeaTimeMailer.delay(run_at: Time.now + 1.hour).ethos(self.user.id)
      end

    elsif self.waiting_list?
      AttendanceMailer.delay.waitlist(self.id)
    end
  end

  def queue_reminders
    start_time = self.tea_time.start_time

    # T - 2day reminder
    two_day_reminder = start_time - 2.days
    if two_day_reminder.future?
      AttendanceMailer.delay(run_at: two_day_reminder).reminder(self.id, :two_day)
    end

    # T - 12hr reminder
    twelve_hour_reminder = start_time - 12.hours
    if twelve_hour_reminder.future?
      AttendanceMailer.delay(run_at: twelve_hour_reminder).reminder(self.id, :same_day)
    end
  end

  def occurred?
    tea_time.occurred?
  end

  class << self
    def host_statuses
      self.statuses.keys - ['waiting_list', 'cancelled', 'pending']
    end
  end
end
