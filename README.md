# TWS

[![Build Status](https://travis-ci.org/TeaWithStrangers/tws-on-rails.svg)](https://travis-ci.org/TeaWithStrangers/tws-on-rails)
[![Coverage Status](https://coveralls.io/repos/TeaWithStrangers/tws-on-rails/badge.png)](https://coveralls.io/r/TeaWithStrangers/tws-on-rails)
[![Code Climate](https://codeclimate.com/github/TeaWithStrangers/tws-on-rails/badges/gpa.svg)](https://codeclimate.com/github/TeaWithStrangers/tws-on-rails)

### Development

TWS is a simple Rails+Postgres app.

To get it set up locally, ensure you have Ruby 2.1.0 and PostgreSQL (w. headers)
installed, then:

```
bundle install

# create a `tws` role in postgres with the
# ability to create databases

createuser tws -d

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
automatically started by the dev Procfile. You'll need to run `gem install mailcatcher`
though, since it's not part of the Gemfile.

# Development / Contributing

Check out our [Contributing Guide](http://making.teawithstrangers.com/contributing).

## Open Commit Bit

TWS has an open commit bit policy: Anyone with an accepted pull request gets
added as a repository collaborator. Please try to follow these simple rules:

* Commit directly onto the master branch only for typos, improvements to the
readme and documentation (please add `[ci skip]` to the commit message).

* Create a feature branch and open a pull request early for any new
features to get feedback.

* Make sure you adhere to the general pull request rules outlined in the
  [contributing guide](http://making.teawithstrangers.com/contributing).

### Contributors

We encourage everyone who contributes to Tea With Strangers' projects to add
themselves to the [list of TWS
teammembers](http://making.teawithstrangers.com/team/).
