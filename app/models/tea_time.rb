class TeaTime < ActiveRecord::Base
  MAX_ATTENDEES = 5
  belongs_to :city
  belongs_to :host, :class_name => 'User', :foreign_key => 'user_id'
  validates_presence_of :host, :start_time, :city, :duration
  has_many :attendances, dependent: :destroy
  
  attr_reader :local_time, :spots_remaining

  scope :past, -> { where("start_time <= ?", DateTime.now.midnight.utc) }
  scope :future, -> { where("start_time >= ?", DateTime.now.midnight.utc) }

  def local_time
    #FIXME: Just use UTC times for now, fix down the line
    start_time#.in_time_zone(city.timezone)
  end

  def start_time
    read_attribute(:start_time) || DateTime.now
  end

  def duration
    read_attribute(:duration) || 2.0
  end

  def friendly_time
    return "#{local_time.strftime("%a, %b %d, %Y,%l")}-#{(local_time+duration.hours).strftime("%-l%P")}"
  end

  def spots_remaining
    MAX_ATTENDEES - (attendances.select(&:pending?).count + 1)
  end

  def spots_remaining?
    spots_remaining > 0
  end

  def attendees
    attendances.map(&:user)
  end

  def cancel!
    UserMailer.tea_time_cancellation(self)
    attendances.map { |att|
      att.status= :cancelled
    }
    update_attributes(start_time: DateTime.new(1900,1,1))
  end

  def ical
    tt = self
    cal = Icalendar::Calendar.new
    Time.use_zone(tt.city.timezone) do
      start_time = Time.zone.parse(tt.start_time.utc.strftime("%Y-%m-%d %H:%M"))
      cal.event do |e|
        e.dtstart = start_time
        e.dtend  = (start_time + tt.duration.hours)
        e.summary = "Tea Time with #{tt.host.name}"
        #FIXME: Come back to this with fresh eyes
        #e.organizer = "CN=#{tt.host.name}:MAILTO:#{tt.host.email}"
        e.location = tt.location
      end
    end
  end

  enum followup_status: [:na, :pending, :sent]

  def todo?
    return !! followup_status != :sent && !attendances.select(&:todo?).empty?
  end
end
