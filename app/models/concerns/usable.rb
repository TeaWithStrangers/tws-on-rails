module Usable
  def role?(role)
    return !! self.roles.find_by_name(role.to_s.camelize)
  end

  Role::VALID_ROLES.each do |role|
    define_method("#{role.downcase}?".to_sym) { role? role }
  end

  def host?
    (admin? || role?(:Host))
  end

  # Devise Methods
  def password_required?
    # Password is required if it is being set, but not for new records
    if !persisted? 
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  # new function to set the password without knowing the current password used in our confirmation controller. 
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end
  # new function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # new function to provide access to protected method unless_confirmed
  def only_if_unconfirmed
    unless_confirmed {yield}
  end
end
