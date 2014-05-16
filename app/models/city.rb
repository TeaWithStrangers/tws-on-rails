class City < ActiveRecord::Base
  validates_uniqueness_of :city_code
  validates_presence_of :city_code, :timezone
  before_save :upcase_code
  has_attached_file :header_bg, default_url: "http://placecorgi.com/1280"
  validates_attachment_content_type :header_bg, :content_type => /\Aimage\/.*\Z/
  enum brew_status: { :cold_water => 0, :warming_up => 1, :fully_brewed => 2}
  has_many :tea_times

  def hosts
    #TODO: Hosts who have nothing scheduled won't show in the hosts partial
    tea_times.future.map(&:host).uniq
  end

  def timezone=(tz)
    val = tz if City.timezone_mappings.key? tz
    if val
      write_attribute(:timezone, val) 
    else
     raise ArgumentError, "TimeZone must be one from TZinfo"
    end
  end

  def to_param
    city_code
  end

  private
    def upcase_code
      write_attribute(:city_code, read_attribute(:city_code).upcase)
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
end

