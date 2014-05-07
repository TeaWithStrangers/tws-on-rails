class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_and_belongs_to_many :roles
  has_many :tea_times
  has_many :attendances
  has_attached_file :avatar, styles: { medium: "300x300", thumb: "100x100"}, default_url: "/assets/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def future_tea_times
    attendee = TeaTime.future.joins(:attendances).where("attendances.status = 0", :user_id => self.id)
    attendee
  end

  def role?(role)
    return !! self.roles.find_by_name(role.to_s.camelize)
  end
  
  Role::VALID_ROLES.each do |role|
    define_method("#{role.downcase}?".to_sym) { role? role }
  end
end
