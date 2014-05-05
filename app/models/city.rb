class City < ActiveRecord::Base
  validates_uniqueness_of :city_code
  validates_presence_of :city_code, :timezone
  has_attached_file :header_bg, default_url: "http://placecorgi.com/1280"
  validates_attachment_content_type :header_bg, :content_type => /\Aimage\/.*\Z/
  enum brew_status: { :cold_water => 0, :warming_up => 1, :fully_brewed => 2}
  has_many :tea_times

  def future_tea_times
    tea_times.where("start_time >= ?", Date.today)
  end

  def past_tea_times
    tea_times.where("start_time < ?", Date.today)
  end

  def hosts
    #TODO: Hosts who have nothing scheduled won't show in the hosts partial
    future_tea_times.map(&:host).uniq
  end

  def timezone=(tz)
    val = City.timezone_mappings[tz]
    if val
      write_attribute(:timezone, val) 
    else
     raise ArgumentError, "TimeZone must be one from TZinfo"
    end
  end

  def to_param
    city_code
  end

  class << self
    def timezone_mappings
      @tzs ||= ActiveSupport::TimeZone::MAPPING
    end

    def for_code(code)
      for_code_proxy(code, :find_by)
    end

    def for_code!(code)
      for_code_proxy(code, :find_by!)
    end

    private
      def for_code_proxy(code, method)
        self.send(method, city_code: code.upcase)
      end
  end

  #FIXME: Shouldn't have to have this at the very end
  validates :timezone, inclusion: { in: City.timezone_mappings.keys }
end
