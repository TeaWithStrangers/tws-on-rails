# Performs a sync of the user DB with SendGrid.

# This system attempts to resolve differences between SendGrid contacts DB
# and the master user database. The user database is the source of truth and
# the system attempts to update the SendGrid contacts DB to keep it consistent
# with what the master user database contains.
#
# Step 1
# It does so by first loading all of the emails in SendGrid (along with their
# corresponding recipient IDs, SendGrid's internal locator for the recipient)
# and putting the set of emails loaded into a set, sg_recipients_emails.
# Then, we load all of the users in the local master user database and convert
# them into a hashmap format.
#
# Step 2
# Next, for each user in the master user database, we do an update (PATCH)
# to SendGrid for that user (in batches of ITEMS_PER_BATCH). If the user does
# not already exist (matched by email), the user will be created. If the user
# does exist, then their details will be updated with the given details. Now,
# all users that are on the master user database should now be in the
# SendGrid contacts DB. As we process each batch, we also remove all of the
# emails that we have processed from sg_recipients_emails, which denotes that
# those users that we received from the SendGrid contacts DB are accounted for
# in the master user database.
#
# Step 3
# Finally, we check if sg_recipients_emails is empty. If the user database
# and SendGrid contacts DB are fully in sync, then every contact loaded from
# the SendGrid contacts DB would have been processed by the loop that
# processed all of the users in the master user database. If there are users
# that are on SendGrid that are not in the master user database, then there
# will be emails in sg_recipients_emails that were not removed by the
# Step 2 processing loop. For each of these emails, we look up the email's
# Recipient ID from the mapping that was loaded earlier and delete each of
# these recipients. Then, we wait for SendGrid to propagate these changes and
# check that the users in the SendGrid contacts DB matches the number of
# users in the master user database.
#
# Cases handled
# - User deleted on master user DB but not deleted on SendGrid contacts DB.
#   The user's email will be loaded in the Step 1 SendGrid contacts DB load.
#   The user will not be processed in the Step 2 loop and their email address
#   will be in the set sg_recipients_emails. In Step 3, the recipient record
#   for that user will be deleted.
# - User changes email on master user DB, now the user has old_email and
#   new_email, both on SendGrid contacts DB (two recipients for the same user).
#   old_email will no longer be in the master user DB, but it will be in
#   SendGrid contacts DB. In Step 3, old_email will be removed as a recipient.
# - User changes email on master user DB, now the user has old_email and
#   new_email. new_email is not in SendGrid contacts DB.
#   Step 2 will create a new recipient for the user with new_email, leading
#   to there being two recipients in SendGrid contacts DB for the same user
#   for a period of time (one for new_email, one for old_email).
#   old_email will no longer be in the master user DB, but it will be in
#   SendGrid contacts DB. In Step 3, old_email will be removed as a recipient.
# - User changes details (e.g. last tea time attended) other than email that
#   is reflected in the master user database but not in SendGrid contact DB.
#   Step 2 will update the user's details in SendGrid to match what is in the
#   master user database.
# - User exists on master user DB but not on SendGrid contacts DB.
#   Step 2 will add the user to the SendGrid contacts DB.
#
# Edge cases
# There are a few edge cases with this strategy (there may be issues if new
# users are created or deleted while this script is running, or if there are
# so many users that it becomes infeasible to store them in memory). In
# addition, the final check may not work correctly if SendGrid's database
# is taking longer to reflect API changes than usual, which means that users
# that were successfully deleted still show up for a period of time. However,
# for most practical purposes this script should work as expected.

require 'sendgrid-ruby'
require 'json'
require 'set'

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
      last_tea_time: user.last_tea_time_date,
      last_sign_in: user.last_sign_in_date
    }
  end
end

def load_sendgrid_contactdb(sg)
  # Loads the SendGrid contacts database and returns
  # - a mapping of emails in the contacts DB to the recipient ID
  # - a set of all emails in the contacts DB

  # sg_recipients_map maps email => recipient_id
  sg_recipients_map = {}

  req_params = {page: 1, page_size: 1000}

  puts 'Loading existing users:'

  while true do
    puts 'Loading page %d' % [req_params[:page]]
    response = sg.client.contactdb.recipients.get(query_params: req_params)

    if response.status_code == '404'
      # End of list
      puts 'Done loading'
      break
    else
      body = JSON.parse(response.body)
      body['recipients'].each do |recipient|
        sg_recipients_map[recipient['email'].downcase] = recipient['id']
      end
    end

    req_params[:page] += 1
    sleep 1
  end

  # sg_recipients_emails is a set of all emails
  sg_recipients_emails = sg_recipients_map.keys.to_set

  return sg_recipients_map, sg_recipients_emails
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

    ##########
    # STEP 1: Load existing SendGrid recipients and user database
    ##########

    # Load existing SendGrid recipients
    sg_recipients_map, sg_recipients_emails = load_sendgrid_contactdb(sg)

    new_count = 0
    updated_count = 0

    users_array = get_users_array
    users_count = users_array.size

    puts '%d users to process' % [users_count]

    ##########
    # STEP 2: Write user database to SendGrid contacts
    ##########

    # Split into batches
    batches = users_array.each_slice(ITEMS_PER_BATCH).to_a

    batches.each_with_index do |batch, index|
      puts 'Running batch %d of %d.' % [index + 1, batches.count]

      # Update user batch to SendGrid
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

      # Remove all users who appeared in this batch from the recipients set
      sg_recipients_emails.subtract(batch.collect {|x| x[:email].downcase})

      sleep 2
    end

    puts '%d new users, %d updated users' % [new_count, updated_count]

    ##########
    # STEP 3: Remove recipients that are on SendGrid but not in user database
    ##########

    # Check for and remove emails on SendGrid not in user database
    # After each batch removes user emails in the DB from sg_recipient_emails,
    # sg_recipient_emails only contains user emails that were loaded from SendGrid
    # contacts but did not appear in the user database
    if sg_recipients_emails.size > 0
      puts '%d emails on SendGrid that were not in user database.' % [sg_recipients_emails.size]

      total_deleted = 0

      # Delete each recipient in SendGrid that are not in user database
      sg_recipients_emails.each do |email|
        # We can only delete by Recipient ID - look up in map table
        recipient_id = sg_recipients_map[email]
        sg.client.contactdb.recipients._(recipient_id).delete

        total_deleted += 1
        puts '%d recipients deleted' % [total_deleted]

        sleep 1
      end

      puts 'Waiting 30 seconds for SendGrid database propagation.'
      sleep 30
    end

    # Final check that recipients in SendGrid == users in DB
    response = JSON.parse(sg.client.contactdb.recipients.get(query_params: {page: 1, page_size: 5}).body)
    if response['recipient_count'] != users_count
      raise('Error: %d in user database != %d in SendGrid contacts' % [users_count, response['recipient_count']])
    else
      puts '%d users in user database, %d recipients in SendGrid contacts' % [users_count, response['recipient_count']]
    end
  end
end
