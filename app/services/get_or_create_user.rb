class GetOrCreateUser
  def self.call(params, home_city)
    #Remove autogen directive from parameters if it exists
    params.delete(:autogen)

    val = {new_user?: true, errors: nil}

    user = User.find_by(email: params[:email])

    if user
      val[:new_user?] = false
    else
      generated_password = Devise.friendly_token.first(8)
      user = User.create(params.merge({home_city: home_city,
                                             password: generated_password}).symbolize_keys)
      UserMailer.delay.registration(user, generated_password)
    end
    return val.merge(user: user)
  end
end
