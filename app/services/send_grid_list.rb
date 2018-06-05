# Helper class to store SendGrid information and
# sync a given user to SendGrid Contacts.
# Does nothing if the API key is not set up in the env.

class SendGridList
  if ENV['SENDGRID_API_KEY']
    @sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  else
    @sg = nil
  end

  # Sync a local User object with the SendGrid contacts DB.
  # 
  # Called after a User is created or updated, or an Attendance record for that
  # user is created or updated.
  # 
  # If the user email changed, then the old SendGrid contact record will be
  # deleted, since SendGrid uses emails as the unique identifier and cannot
  # detect a user email change.
  # 
  # If the user exists already on SendGrid, their details will be updated.
  # If the user does not already exist on SendGrid, a record will be created.
  # 
  # @param <User> user The User object to sync.
  # @param <Boolean> new_record Whether or not this callback is from creating a
  # new user.
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
        last_tea_time: user.last_tea_time_date,
        last_sign_in: user.last_sign_in_date,
        sign_in_count: user.sign_in_count
      }

      @sg.client.contactdb.recipients.patch(request_body: [user_hash])
    end
  end

  # Delete a user from the SendGrid contacts DB.
  # 
  # Called after a User is destroyed.
  # 
  # @param <User> user The user to delete.
  def self.delete_user(user)
    # When a user deletes their account, remove them from the mailing list.
    self.delete_user_by_email(user.email)
  end

  # Deletes a user by email from the SendGrid contacts DB.
  # @param <String> email The email for the contact record to delete.
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

  # Gets all segments in the database, returning the name and ID.
  #
  # @return [Array<Array<String, Integer>>] An array of arrays, the inner
  # array containing [segment_name, segment_id].
  def self.get_segments
    if @sg
      segments_response = @sg.client.contactdb.segments.get
      if segments_response.status_code != '200'
        raise('Error fetching segments')
      else
        resp = JSON.parse(segments_response.body)
        segments = resp['segments'].map do |segment|
          segment_name = '%s (%d)' % [segment['name'], segment['recipient_count']]
          [segment_name, segment['id']]
        end
        return segments.to_a
      end
    else
      []
    end
  end

  # Create a SendGrid list with the union of the specified segments.
  #
  # A set is generated which is the union of all of the recipients in
  # all of the specified segments.
  #
  # If `sample` is nil, all recipients are retained. If `sample` is an
  # integer, then a random sample of size `sample` is taken from the
  # recipients set.
  #
  # A list is created with the resulting recipients with name `name`.
  #
  # @param [String] name Name of the list to create.
  # @param [Array<Integer>] segments List of segments to combine.
  # @param [Integer] sample Size of the random sample to take, or nil to retain all recipients.
  #
  # @return [Union<Integer, Boolean>] Integer list_id if successful, false if error.
  def self.create_list_from_segments(name, segments, sample)
    # Creates a SendGrid List corresponding to the union of the segments in
    # `segments` and with a random sample of `sample` (which can be blank).
    if @sg
      all_recipients = get_recipients(segments).to_a

      # If a sample is requested, take a sample
      unless sample.blank?
        if sample.is_a?(String)
          sample = sample.to_s.delete(',').to_i
        end
        all_recipients = all_recipients.sample(sample)
      end

      # Create list
      create_list_response = @sg.client.contactdb.lists.post(request_body: {name: name})
      if create_list_response.status_code == '201'
        # Get list ID
        create_list_body = JSON.parse(create_list_response.body)
        list_id = create_list_body['id']

        # Batch recipients
        batches = all_recipients.each_slice(1000).to_a

        # Loop through each batch
        batches.each_with_index do |batch, index|
          puts 'Running batch %d of %d.' % [index + 1, batches.count]
          post_recipients_response = @sg.client.contactdb.lists._(list_id).recipients.post(request_body: batch)

          # Catch error
          if post_recipients_response.status_code != '201'
            return false
          end

          # Rate limit
          sleep 1.5
        end

        list_url = 'https://sendgrid.com/marketing_campaigns/ui/lists/%d' % [list_id]

        # Email notification with results
        r = @sg.client.mail._("send").post(request_body: {
            "from": {
               "email": "ankit@teawithstrangers.com"
            },
            "personalizations": [
                {
                    "to": [ { "email": "ankit@teawithstrangers.com" } ] ,
                    "subject": "Segment Assembler: list created: %s" % [name]
                }
            ],
            "content": [
                {
                    "type": "text/plain",
                    "value": "Your list %s has been created: %s" % [name, list_url]
                }
            ]
        })

        return list_id
      else
        return false
      end
    else
      return false
    end
  end

  # Get a list of all recipients for an array of segments.
  # 
  # Takes the union of all of the recipients from each segment, i.e. no
  # recipient is duplicated in the list.
  # 
  # Returns a set of recipient_ids, the identifier for recipients in SendGrid.
  # 
  # @param [Array<Integer>] Array of segment IDs to get recipients for.
  # @return [Set<String>] Set of recipient_ids for these segments.
  def self.get_recipients(segments)
    if @sg
      all_recipients = Set[]
      segments.each do |segment|
        if segment != ""
          all_recipients.merge(get_segment_recipients(segment))
        end
      end

      return all_recipients
    end
  end

  # Get a list of all recipients for a given segment.
  # 
  # Fetches recipients 1000 records at a time from the segment until 404 is
  # reached (denoting end of list).
  # 
  # @param [Integer] segment_id Segment ID to fetch recipients for.
  # @return [Set<Integer>] Set of recipient_ids for this segment.
  def self.get_segment_recipients(segment_id)
    if @sg
      puts 'Fetching segment %s' % [segment_id]
      query_params = {page: 1, page_size: 1000}

      recipients = Set[]

      while true do
        puts 'Fetching page %d' % [query_params[:page]]
        segment_response = @sg.client.contactdb.segments._(segment_id).recipients.get(query_params: query_params)

        if segment_response.status_code == '404'
          # End of results
          sleep 1
          break
        elsif segment_response.status_code != '200'
          raise('Error fetching segment')
        end

        segment_body = JSON.parse(segment_response.body)
        recipients.merge(segment_body['recipients'].collect {|recipient| recipient['id']})

        # Next page
        query_params[:page] += 1
        sleep 1
      end

      return recipients
    end
  end

  # Unsubscribe the given email from the newsletter.
  #
  # Makes 3 attempts to unsubscribe. If all fail, then return false.
  #
  # The request happens in the add_to_unsubscribe_group() method.
  #
  # @param [String] email Email to unsubscribe
  # @return [Boolean] true if successful, false if not successful.
  def self.newsletter_unsubscribe(email)
    if @sg
      # Make 3 attempts to unsubscribe
      for attempt in 1..3 do
        if add_to_unsubscribe_group(email)
          # Success, return early
          return true
        else
          # Failed to unsubscribe, potentially because of API rate limit
          sleep 1
        end
      end

      # Three attempts made, failed
      return false
    else
      # No SendGrid API credentials loaded
      return false
    end
  end

  # Make a call to SendGrid API to unsubscribe an email by adding it to the
  # unsubscribe group with the ID set in env SENDGRID_NEWSLETTER_UNSUB_GROUP.
  #
  # This is not called directly by the controller. This method only handles the
  # request logic to the SendGrid API.
  #
  # newsletter_unsubscribe is called by the controller.
  # newsletter_unsubscribe may call this multiple times in case of failure.
  #
  # Note: if the SENDGRID_NEWSLETTER_UNSUB_GROUP variable is set to an invalid
  # unsubscribe group, the email will be added to the global unsubscribe list.
  #
  # @param [String] email Email to unsubscribe
  # @return [Boolean] true if successful, false if not successful.
  def self.add_to_unsubscribe_group(email)
    if @sg
      data = {'recipient_emails': [email]}
      response = @sg.client.asm.groups._(ENV['SENDGRID_NEWSLETTER_UNSUB_GROUP']).suppressions.post(request_body: data)
      if response.status_code == '201'
        # Ensure the body contains the exact email unsubscribed
        resp = JSON.parse(response.body)
        if !resp['recipient_emails'].nil? and !resp['recipient_emails'][0].nil? and resp['recipient_emails'][0] === email
          # Successfully added
          return true
        end

        # Failed to match returned email, fail
        return false
      else
        # Response code not 201, fail
        return false
      end
    else
      # No SendGrid credentials, fail
      return false
    end
  end
end