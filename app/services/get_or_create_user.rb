class GetOrCreateUser
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
      password = Devise.friendly_token.first(8)
      user = User.create(params.merge({home_city: home_city,
                                       password: password}).symbolize_keys)
      UserMailer.delay.registration(user, password)
    end

    return val.merge(user: user)
  end
end
