class Host < User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #
  # Hosts inherit from user but is limited to those with host bit set
  default_scope {
    joins(:roles).where(roles: {name: 'Host'})
  }

end
