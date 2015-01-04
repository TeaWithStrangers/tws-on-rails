module Roleable
  DEFAULT_ROLES = %w{}

  module ClassMethods
    def valid_roles
      const_get(:ROLES) || Roleable::DEFAULT_ROLES
    end

    def role_mask(*roles)
      roles.flatten!.map! {|r| r.to_s.downcase}
      (roles & valid_roles).map { |r| 
        2**valid_roles.index(r) 
      }.inject(0, :+)
    end
  end

  def self.included(base)
    unless base.const_defined?(:ROLES)
      base.const_set :ROLES, Roleable::DEFAULT_ROLES
    end

    base.extend Roleable::ClassMethods

    base.valid_roles.each do |role|
      base.send(:define_method, "#{role.downcase}?".to_sym) { role? role }
    end
  end

    def roles=(roles)
      self.roles_mask = self.class.role_mask(roles)
    end

    def roles
      self.class.valid_roles.reject do |r|
        ((roles_mask.to_i || 0) & 2**self.class.valid_roles.index(r)).zero?
      end
    end

    def role?(role)
      return !! self.roles.include?(role.to_s.downcase)
    end
end
