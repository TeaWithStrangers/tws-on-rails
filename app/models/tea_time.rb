class TeaTime < ActiveRecord::Base
  MAX_ATTENDEES = 5
  belongs_to :city
  belongs_to :host, :class_name => 'User', :foreign_key => 'user_id'
  validates_presence_of :host, :start_time, :city, :duration
  has_many :attendances, dependent: :destroy

  after_touch :clear_association_cache_wrapper

  enum followup_status: [:na, :pending, :sent, :cancelled]

  TeaTime.followup_statuses.each do |k,v|
    scope k, -> { where(followup_status: v) }
  end
  scope :before, ->(date)  { where("start_time <= ?", date) }
  scope :after, ->(date)  { where("start_time >= ?", date) }
  scope :past, -> { before(Time.now.midnight.utc) }
  scope :future, -> { after(Time.now.midnight.utc) }
  scope :future_until, ->(until_time) { future.before(until_time) }

  def start_time
    return use_city_timezone { super.in_time_zone if super } || Time.now
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
    MAX_ATTENDEES - attendances.select(&:pending?).count
  end

  def spots_remaining?
    spots_remaining > 0
  end
  
  #Attendees takes an optional single argument lambda via the :filter keyword arg
  # that is passed to reject. Any items for which the Proc returns true are
  # excluded from the returned list of attendees.
  def attendees(filter: nil)
    attendances.reject(&filter).map(&:user)
  end
  
  #Takes :filter, same as attendees
  def all_attendee_emails(filter: nil)
    attendees(filter: filter).map(&:email).join(',')
  end

  def cancel!
    unless cancelled?
      # Until we move mailers into something like DJ we run the risk of a failed
      # email send blocking cancellation and ruining everything. If that happens
      # I rather abort and return the Requesting thread than 500 error. This is
      # a short-term fix
      begin 
        self.followup_status = :cancelled
        self.save!
        UserMailer.tea_time_cancellation(self)
        attendances.map { |att|
          att.status = :cancelled
          att.save
        }
        return true
      rescue Exception => e
        return false
      end
    end
  end

  def ical
    tt = self
    cal = Icalendar::Calendar.new
    Time.use_zone(tt.city.timezone) do
      start_time = Time.zone.parse(tt.start_time.utc.strftime("%Y-%m-%d %H:%M"))
      cal.event do |e|
        e.dtstart = start_time
        e.dtend  = (start_time + tt.duration.hours)
        e.summary = "Tea time with #{tt.host.name}"
        #FIXME: Come back to this with fresh eyes
        #e.organizer = "CN=#{tt.host.name}:MAILTO:#{tt.host.email}"
        e.location = tt.location
      end
      cal
    end
  end

  def todo?
    return !! followup_status != :sent && !attendances.select(&:todo?).empty?
  end

  private
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
