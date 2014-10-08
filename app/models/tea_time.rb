class TeaTime < ActiveRecord::Base
  # Only soft-delete tea times
  acts_as_paranoid

  validates_presence_of :host, :start_time, :city, :duration
  validate :attendance_marked?, if: :pending?

  belongs_to :city
  belongs_to :host, :class_name => 'User', :foreign_key => 'user_id'

  MAX_ATTENDEES = 5
  has_many :attendances, dependent: :destroy
  accepts_nested_attributes_for :attendances

  after_touch :clear_association_cache_wrapper
  after_create :send_host_confirmation, :queue_followup_mails, unless: :skip_callbacks
  before_destroy { CancelTeaTime.send_cancellation(self) }

  enum followup_status: { pending: 0, marked_attendance: 1, completed: 2, cancelled: 3 }

  TeaTime.followup_statuses.each do |k,v|
    scope k, -> { where(followup_status: v) }
  end

  scope :before, ->(date)  { where("start_time <= ?", date) }
  scope :after, ->(date)  { where("start_time >= ?", date) }
  scope :past, -> { before(Time.now.utc) }
  scope :future, -> { after(Time.now.utc) }
  scope :future_until, ->(until_time) { future.before(until_time) }

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

  def duration
    read_attribute(:duration) || 2
  end

  def friendly_time
    start_t = start_time
    end_t = (start_t+duration.hours)
    date = start_t.strftime("%a, %b %d, %Y").strip
    meridian = end_t.strftime("%P")

    startT = start_t.strftime("%-l:%M")
    endT = end_t.strftime("%-l:%M")
    [startT, endT].each {|ft|
      ft.gsub!(":00", "")
    }

    "#{date}, #{startT}-#{endT}#{meridian}"
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

  #Attendees takes an optional single argument lambda via the :filter keyword arg
  # that is passed to reject. Any items for which the Proc returns true are
  # excluded from the returned list of attendees.
  def attendees(filter: nil)
    attendances.reject(&filter).map(&:user)
  end

  #Takes :filter, same as attendees
  def attendee_emails(filter: nil)
    attendees(filter: filter).map(&:email).join(',')
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

  def ical
    tt = self
    cal = Icalendar::Calendar.new
    cal.event do |e|
      e.dtstart = tt.start_time
      e.dtend  = (tt.start_time + tt.duration.hours)
      e.summary = "Tea time, hosted by #{tt.host.name}"
      #FIXME: Come back to this with fresh eyes
      #e.organizer = "CN=#{tt.host.name}:MAILTO:#{tt.host.email}"
      e.location = tt.location
    end
    cal
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

  def queue_followup_mails
    TeaTimeMailer.delay(run_at: self.end_time).followup(self.id)
  end

  def to_s
    "#{host.name} – #{location} @ #{friendly_time}"
  end

  private
    def attendance_marked?
      if !attendances.pending.count.zero?
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
