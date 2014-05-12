class TeaTime < ActiveRecord::Base
  MAX_ATTENDEES = 5
  belongs_to :city
  belongs_to :host, :class_name => 'User', :foreign_key => 'user_id'
  validates_presence_of :host, :start_time, :city, :duration
  has_many :attendances, dependent: :destroy
  
  attr_reader :local_time, :spots_remaining

  scope :past, -> { where("start_time <= ?", DateTime.now.midnight) }
  scope :future, -> { where("start_time >= ?", DateTime.now.midnight) }

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

  enum followup_status: [:na, :pending, :sent]

  def todo?
    return !! followup_status != :sent && !attendances.select(&:todo?).empty?
  end
end
