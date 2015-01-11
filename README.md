# TWS

[![Build Status](https://travis-ci.org/TeaWithStrangers/tws-on-rails.svg)](https://travis-ci.org/TeaWithStrangers/tws-on-rails)
[![Coverage Status](https://coveralls.io/repos/TeaWithStrangers/tws-on-rails/badge.png)](https://coveralls.io/r/TeaWithStrangers/tws-on-rails)
[![Code Climate](https://codeclimate.com/github/TeaWithStrangers/tws-on-rails/badges/gpa.svg)](https://codeclimate.com/github/TeaWithStrangers/tws-on-rails)

### Development

This is a simple Rails app with a Postgres database.

To get it set up locally, make sure you have Ruby, Postgres, and Foreman
installed, then:


```
git clone https://github.com/TeaWithStrangers/tws-on-rails.git tws
cd tws
bundle install

# create a `tws` role in postgres with the
# ability to create databases
sudo -u postgres createuser tws -d

# set user password to 123456 (change if desired)
echo "ALTER USER tws PASSWORD '123456';" | sudo -u postgres psql

# save the password (same as above) in the environment
# also add this to ~/.bash_profile so that it will always be set
export TWS_DB_PASSWORD=123456

# create the dev and test databases
rake db:create

# Load the schema
rake db:schema:load

# Run the App

foreman -f Procfile-dev

# For Development
# Create some development data to play arond with
# This includes creating roles
# This will drop the database if it exists and create it again.
rake db:seed_dev
```

#### Mail

In development, all outgoing email will be intercepted by `mailcatcher`
and will be previewable at `http://localhost:1080`. The mailcatcher instance is
automatically started by the dev Procfile.
