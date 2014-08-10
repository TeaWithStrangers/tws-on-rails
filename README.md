# TWS

[![Build Status](https://travis-ci.org/TeaWithStrangers/tws-on-rails.svg)](https://travis-ci.org/TeaWithStrangers/tws-on-rails)
[![Coverage Status](https://coveralls.io/repos/TeaWithStrangers/tws-on-rails/badge.png)](https://coveralls.io/r/TeaWithStrangers/tws-on-rails)

### Development

This is a simple Rails app with a Postgres database.

To get it set up locally, make sure you have Ruby and Postgres
installed, then:


```
git clone https://github.com/TeaWithStrangers/tws-on-rails.git tws
cd tws
bundle install

# create a `tws` role in postgres with the
# ability to create databases
createuser tws -d

# create the dev and test databases
rake db:create

# Load the schema
rake db:schema:load

# Start mailcatcher in the background
mailcatcher & # preview email at localhost:1080

# Start the server
rails s

# For Development
# Create some development data to play arond with
# This includes creating roles
# This will drop the database if it exists and create it again.
rake db:seed_dev
```

#### Mail

In development, all outgoing email will be intercepted by `mailcatcher`
and will be previewable at `http://localhost:1080`.
All you have to do is start the mailcatcher server as specified
in the directions above (`mailcatcher &` in terminal).
