# Helper class to store SendGrid information and
# sync a given user to SendGrid Contacts.
# Does nothing if the API key is not set up in the env.

class SendGridList
  if ENV['SENDGRID_API_KEY']
    @sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  else
    @sg = nil
  end

  def self.sync_user(user, new_record = false)
    # Ensure the user is not deleted
    if @sg and !user.deleted_at
      # When a user email changes, we delete the old recipient record
      # Then we can insert the new one with the updated email
      if !new_record and user.changes[:email]
        # User email changed
        # Remove the recipient with the previous email
        previous_email = user.changes[:email][0]
        self.delete_user_by_email(previous_email)
      end

      user_hash = {
        user_id: user.id,
        name: user.name,
        first_name: user.given_name,
        last_name: user.family_name,
        email: user.email,
        join_date: user.created_at.to_date.strftime('%s'),
        home_city: user.home_city ? user.home_city.name : '',
        user_type: user.admin? ? 'admin' : (user.host? ? 'host' : 'user'),
        tea_times_attended: user.tea_times_attended,
        last_tea_time: user.last_tea_time_date
      }

      @sg.client.contactdb.recipients.patch(request_body: [user_hash])
    end
  end

  def self.delete_user(user)
    # When a user deletes their account, remove them from the mailing list.
    self.delete_user_by_email(user.email)
  end

  def self.delete_user_by_email(email)
    if @sg
      user_response = @sg.client.contactdb.recipients.search.get(query_params: {email: email})
      if user_response.status_code == "200"
        resp = JSON.parse(user_response.body)
        if resp['recipient_count'] > 0
          id = resp['recipients'][0]['id']
          @sg.client.contactdb.recipients._(id).delete
        end
      end
    end
  end
end