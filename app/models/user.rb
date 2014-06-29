class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_and_belongs_to_many :roles
  has_many :tea_times
  has_many :attendances
  belongs_to :home_city, class_name: 'City'
  has_attached_file :avatar, styles: { medium: "300x300", thumb: "100x100", landscape: "500"}, default_url: "/assets/missing.jpg"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  validates_presence_of :home_city_id

  scope :hosts, -> { joins(:roles).where(roles: {name: 'Host'}) }

  def future_hosts
    now = DateTime.now.utc.midnight
    inclusive_of = (now..(now+2.weeks))
    tea_times.where(start_time: inclusive_of)
  end

  def future_attendances
    attendances.where(status: 0).joins(:tea_time).
      merge(TeaTime.future).includes(:tea_time)
  end

  def role?(role)
    return !! self.roles.find_by_name(role.to_s.camelize)
  end

  Role::VALID_ROLES.each do |role|
    define_method("#{role.downcase}?".to_sym) { role? role }
  end

  def host?
    (admin? || role?(:Host))
  end
end
