class User < ActiveRecord::Base
  include Usable
  acts_as_paranoid

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :tea_times
  has_many :attendances
  belongs_to :home_city, class_name: 'City'

  has_attached_file :avatar, styles: { medium: "300x300", thumb: "100x100", landscape: "500"}, default_url: "/assets/missing.jpg"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  validates_presence_of :home_city_id, :name

  include ActiveModel::Validations
  validates_with Validators::FacebookUrlValidator
  validates_with Validators::TwitterHandleValidator

  #We want to send our own confirmation link
  before_create :skip_confirmation_notification!
  before_destroy :flake_future

  bitmask :roles, :as => [:host, :admin], :null => false
  alias_method :role?, :roles?
  scope :hosts, -> { with_roles :host }

  def twitter_url
    "https://twitter.com/#{twitter}" if twitter
  end

  def facebook_url
    "https://facebook.com/#{facebook}" if facebook
  end

  def future_hosts
    tea_times.future_until Time.now.utc+2.weeks
  end

  def future_attendances
    attendances.where(status: 0).joins(:tea_time).
      merge(TeaTime.future).includes(:tea_time)
  end

  def friendly_email
    "\"#{self.name}\" <#{self.email}>"
  end

  def admin?
    role? :admin
  end

  def host?
    (admin? || role?(:host))
  end

  def attendances_for(tt_period)
    attendances.joins(:tea_time).
      merge(tt_period).includes(:tea_time)
  end

  def flake_future
    attendances_for(TeaTime.future).each do |a|
      a.flake!(email: false)
    end
  end

  class << self
    def nil_user
      @@nil_user ||= NilUser.new
    end
  end
end

class NilUser
  alias_method :persisted?, :blank?

  def marked_for_destruction?
    false
  end

  def name
    "A Former Tea Timer"
  end

  def email
    nil
  end

  def blank?
    true
  end

  def id
    nil
  end
end
