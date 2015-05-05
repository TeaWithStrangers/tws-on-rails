class GetOrCreateWaitlistedUser
  # Returns a hash with keys :user and :new_user?
  # :user => User, :new_user? => Boolean
  def self.call(params, home_city)
    #Remove autogen directive from parameters if it exists
    params.delete(:autogen)

    val = {new_user?: true, errors: nil}

    user = User.find_by(email: params[:email])

    if user
      val[:new_user?] = false
    else
      user = User.new(params)
      UserMailer.delay.waitlisted_registration(user)
    end

    return val.merge(user: user)
  end
end
