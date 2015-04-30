class Ability
  include CanCan::Ability 

  def initialize(user)
    user ||= User.new # guest user 

    if user.role? :admin
      can :manage , :all
    elsif user.role? :host
      can :manage, TeaTime, :host_id => user.id
      can :create, TeaTime
      can :update, Attendance
      can :read, User
    else
      can :read, User, :id => user.id
      can :update, Attendance, :user_id => user.id
    end 
  end 
end 
