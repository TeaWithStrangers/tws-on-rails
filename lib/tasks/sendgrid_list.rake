# Performs a sync of the user DB with SendGrid.
# Currently only a one-way sync.

require 'sendgrid-ruby'
require 'json'

# Number of users to update per API call
ITEMS_PER_BATCH = 1000

def get_users_array
  users = User.all
  users_array = users.map do |user|
    {
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
  end
end

namespace :sendgrid_list do
  desc "System for syncing user database with SendGrid Contacts."
  task sync: :environment do
    if ENV['SENDGRID_API_KEY']
      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    else
      p "No SendGrid credentials available."
      return
    end

    new_count = 0
    updated_count = 0

    users_array = get_users_array

    puts '%d users to create' % [users_array.count]

    # Split into batches
    batches = users_array.each_slice(ITEMS_PER_BATCH).to_a

    batches.each_with_index do |batch, index|
      puts 'Running batch %d of %d.' % [index + 1, batches.count]

      response = sg.client.contactdb.recipients.patch(request_body: batch)
      puts response.status_code
      resp = JSON.parse(response.body)
      puts resp

      # Stop sync if SendGrid reports an error.
      if resp['error_count'] > 0
        raise('Error')
      end

      new_count += resp['new_count']
      updated_count += resp['updated_count']

      sleep 2
    end

    puts '%d new users, %d updated users' % [new_count, updated_count]
  end
end
