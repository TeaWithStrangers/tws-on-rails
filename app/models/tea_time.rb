class TeaTime < ActiveRecord::Base
  # Only soft-delete tea times
  acts_as_paranoid

  validates_presence_of :host, :start_time, :city, :duration
  validate :attendance_marked?, if: :occurred?
  validate :occurs_in_past?, on: :create
  belongs_to :city
  belongs_to :host, :class_name => 'User', :foreign_key => 'user_id'

  MAX_ATTENDEES = 5
  has_many :attendances, dependent: :destroy
  accepts_nested_attributes_for :attendances

  after_touch :clear_association_cache_wrapper

  after_commit :queue_reminder_to_mark_attendance,
               :send_host_confirmation,
               on: :create, unless: :skip_callbacks
  after_commit :queue_host_nudge_email, on: :create

  before_destroy { CancelTeaTime.send_cancellations(self) }

  enum followup_status: { pending: 0, marked_attendance: 1, completed: 2, cancelled: 3 }

  TeaTime.followup_statuses.each do |k,v|
    scope k, -> { where(followup_status: v) }
  end

  scope :before, ->(date)  { where("start_time <= ?", date) }
  scope :after, ->(date)  { where("start_time >= ?", date) }
  scope :past, -> { before(Time.now.utc) }
  scope :future, -> { after(Time.now.utc) }
  scope :future_until, ->(until_time) { future.before(until_time) }
  scope :not_cancelled, -> { where("followup_status != 3") }
  scope :this_month, -> { after(Date.today).before(Time.now.at_end_of_month).not_cancelled }
  scope :next_month, -> { after(Date.today.at_beginning_of_month.next_month).before(Time.now.at_beginning_of_month.next_month.at_end_of_month).not_cancelled }

  def date
    start_time.strftime("%A, %D")
  end

  def attendees_with_shareable_phone_numbers
    attendances.where(provide_phone_number: true).map(&:user)
  end

  def day_date
    start_time.strftime("%A, %b %e")
  end

  def date_to_email
    start_time.strftime("%A, %b %e at %I:%M%P")
  end

  def day
    start_time.strftime("%A")
  end

  def date_sans_year
    start_time.strftime("%b %e")
  end

  def date_full_month_sans_year
    start_time.strftime("%B %e")
  end


  def host_name
    host.name if host
  end

  def start_time
    return use_city_timezone { super.in_time_zone if super } || Time.now
  end

  def end_time
    self.start_time + self.duration.hours
  end

  def start_time=(time)
    if city
      write_attribute(:start_time, reparse_time_in_tz(time))
    else
      super
    end
  end

  def occurs_in_past?
    if Time.now >= self.start_time
      errors.add(:start_time, 'must be a future time')
      false
    else
      true
    end
  end

  def duration
    read_attribute(:duration) || 2
  end

  def friendly_time
    start_t         = start_time
    end_t           = start_t + duration.hours
    start_meridian  = start_t.strftime("%P")
    end_meridian    = end_t.strftime("%P")

    date            = start_t.strftime("%a, %b %d, %Y").strip


    startT    = start_t.strftime("%-l:%M")
    endT      = end_t.strftime("%-l:%M")

    [startT, endT].each {|ft|
      ft.gsub!(":00", "")
    }

    timestamp = if start_meridian.match(end_meridian)
      "#{startT}-#{endT}#{end_meridian}"
    else
      "#{startT}#{start_meridian}-#{endT}#{end_meridian}"
    end

    return "#{date}, #{timestamp}"
  end

  def start_end_hour
    start_t         = start_time
    end_t           = start_t + duration.hours
    start_meridian  = start_t.strftime("%P")
    end_meridian    = end_t.strftime("%P")

    startT    = start_t.strftime("%-l:%M")
    endT      = end_t.strftime("%-l:%M")

    [startT, endT].each {|ft|
      ft.gsub!(":00", "")
    }

    timestamp = if start_meridian.match(end_meridian)
      "#{startT} – #{endT}#{end_meridian}"
    else
      "#{startT}#{start_meridian} – #{endT}#{end_meridian}"
    end

    return "#{timestamp}"
  end

  def spots_remaining
    MAX_ATTENDEES - attendances.pending.count
  end

  def spots_remaining?
    spots_remaining > 0
  end

  def attending?(user)
    !attendances.where(user: user, status: Attendance.statuses[:pending]).empty?
  end

  def waitlisted?(user)
    !attendances.where(user: user, status: Attendance.statuses[:waiting_list]).empty?
  end

  # Attendees takes an optional single argument lambda via the :filter keyword arg
  # that is passed to reject. Any items for which the Proc returns true are
  # excluded from the returned list of attendees.
  def attendees(filter: nil)
    attendances.reject(&filter).map(&:user)
  end

  #Takes :filter, same as attendees
  def attendee_emails(filter: nil)
    attendees(filter: filter).map(&:email).join(',')
  end

  def attendee_emails_by_status(status)
    attendee_emails(filter: ->(x) { x.status != status })
  end

  def attendee_emails_pretty(filter: nil)
    attendees(filter: filter).map{|f| "\"#{f.nickname}\" <#{f.email}>"}.join(', ')
  end

  def occurred?
    return !cancelled? && Time.now >= end_time
  end

  def cancel!
    unless cancelled?
      attendances.map do |att|
        att.update_attribute(:status, :cancelled) if att.pending?
      end
      return self.update_attribute(:followup_status, :cancelled)
    else
      false
    end
  end

  def todo?
    return !! followup_status != :sent && !attendances.select(&:todo?).empty?
  end

  def send_host_confirmation
    TeaTimeMailer.delay.host_confirmation(self.id)
  end

  def send_waitlist_notifications
    AttendanceMailer.delay.waitlist_free_spot(self.id)
  end

  def queue_reminder_to_mark_attendance
    AttendanceMailer.delay(run_at: self.end_time + 30.minutes).mark_attendance_reminder(self.id)
  end

  def advance_state!
    #TODO: Transform all these psuedo-state machines into actual ones
    new = nil

    case followup_status
    when 'pending'
      if valid?
        new = :marked_attendance
      end
    when 'marked_attendance'
      new = :completed
      Delayed::Job.enqueue(TeaTimeFollowupNotifier.new(self.id))
    end

    if new
      update!(followup_status: new)
    else
      false
    end

  end

  def to_s
    "#{host.name} – #{location} @ #{friendly_time}"
  end

  private
    # schedule 1 OR 2 days before  depending on how far away it is
    def queue_host_nudge_email
      days_before = days_till_tea_time_start <= 2 ? 1 : 2
      schedule_time = start_time - days_before.send(:days)
      HostMailer.delay(run_at: schedule_time).pre_tea_time_nudge(self.id)
    end

    def days_till_tea_time_start
      return 0 if !start_time
      seconds_in_float = start_time - Time.now
      (seconds_in_float / 60 / 60 / 24).round # round days to whole number
    end

    def attendance_marked?
      if !attendances.inject(Hash.new(0)) { |hsh, a| hsh[a.status] += 1; hsh }['pending'].zero?
        errors.add(:attendances, 'must be marked')
      end
    end

    def use_city_timezone(&block)
      unless city.nil?
        Time.use_zone(city.timezone, &block)
      else
        block.call
      end
    end

    def reparse_time_in_tz(time)
      use_city_timezone do
        fmt = "%Y-%m-%d %H:%M"
        time.strftime(fmt)
        Time.zone.parse(time.strftime(fmt))
      end
    end

    def clear_association_cache_wrapper
      clear_association_cache
    end
end
