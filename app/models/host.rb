class Host < User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_and_belongs_to_many :roles, foreign_key: 'user_id'
  has_many :tea_times
  has_many :attendances
  has_attached_file :avatar, styles: { medium: "300x300", thumb: "100x100"}, default_url: "/assets/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  # Hosts inherit from user but is limited to those with host bit set
  default_scope {
    joins(:roles).where(roles: {name: 'Host'})
  }

end
