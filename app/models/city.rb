class City < ActiveRecord::Base
  validates_uniqueness_of :city_code
  validates_presence_of :city_code, :timezone
  before_save :upcase_code
  has_attached_file :header_bg, default_url: "http://placecorgi.com/1280"
  validates_attachment_content_type :header_bg, :content_type => /\Aimage\/.*\Z/
  enum brew_status: { cold_water: 0, warming_up: 1, fully_brewed: 2, hidden: 3}
  has_many :tea_times
  has_one :proxy_city, foreign_key: :proxy_city_id, class: City
  validate :proxy_city_not_self
  has_many :users, foreign_key: 'home_city_id'

  default_scope { where.not(brew_status: brew_statuses[:hidden]) }
  scope :hidden, ->() { unscoped.where(brew_status: brew_statuses[:hidden]) }

  def hosts
    User.hosts.where(home_city: self)
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

  def tea_times
    tts = (proxy_city.tea_times if proxy_city) || []
    tts + super
  end

  private
    def upcase_code
      write_attribute(:city_code, read_attribute(:city_code).upcase)
    end

    # Having self as proxy creates an infinite chain of queries when
    # attempting to resolve tea times for the city.
    def proxy_city_not_self
      errors.add(:proxy_city) if (proxy_city && proxy_city.id == self.id)
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

