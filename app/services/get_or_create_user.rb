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
      user = User.create(params.merge({home_city: home_city}).symbolize_keys)
      email_token = user.confirmation_token
      new_token = Devise.token_generator.digest(User, :confirmation_token, user.confirmation_token)
      user.update_attribute(:confirmation_token, new_token)
      UserMailer.delay.registration(user, email_token)
    end

    return val.merge(user: user)
  end
end
