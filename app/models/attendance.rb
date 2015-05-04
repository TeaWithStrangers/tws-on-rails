class Attendance < ActiveRecord::Base
  # Attendances should never be deleted, only soft-deleted
  acts_as_paranoid

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
    job = AttendanceReminderJob.new(tea_time)

    if Time.now < job.two_day_reminder_time
      job.two_day_reminder(id)
    end

    if Time.now < job.twelve_hour_reminder_time
      job.twelve_hour_reminder(id)
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

  class << self
    def host_statuses
      self.statuses.keys - ['waiting_list', 'cancelled', 'pending']
    end
  end
end
