# TWS

[![Build Status](https://travis-ci.org/TeaWithStrangers/tws-on-rails.svg)](https://travis-ci.org/TeaWithStrangers/tws-on-rails)
[![Coverage Status](https://coveralls.io/repos/TeaWithStrangers/tws-on-rails/badge.png)](https://coveralls.io/r/TeaWithStrangers/tws-on-rails)
[![Code Climate](https://codeclimate.com/github/TeaWithStrangers/tws-on-rails/badges/gpa.svg)](https://codeclimate.com/github/TeaWithStrangers/tws-on-rails)

### Development

TWS is a simple Rails+Postgres app.

Prerequisites:

- Ruby
- Postgres


```shell
bundle install
createuser tws -d       # create postgres role
rake db:create          # create the dev and test databases
gem install mailcatcher # install local mail server interceptor
mailcatcher             # start background server to intercept mail
rake db:seed_dev        # Loads schema and creates some custom play data
rails s

# Log in with user@tws.com with password `secret1234`
```

# Running Tests

```shell
bundle install
rake
```

#### Mail

In development, all outgoing email will be intercepted by `mailcatcher`
and will be previewable at `http://localhost:1080`. The mailcatcher instance is
automatically started by the dev Procfile. You'll need to run `gem install mailcatcher`
though, since it's not part of the Gemfile.

# Development / Contributing

Check out our [Contributing Guide](http://making.teawithstrangers.com/contributing).

We encourage everyone who contributes to Tea With Strangers' projects to add
themselves to the [list of TWS team members](http://making.teawithstrangers.com/team/).

## Open Commit Bit

TWS has an open commit bit policy: Anyone with an accepted pull request gets
added as a repository collaborator. Please try to follow these simple rules:

* Commit directly onto the master branch only for typos, improvements to the
readme and documentation (please add `[ci skip]` to the commit message).

* Create a feature branch and open a pull request early for any new
features to get feedback.

* Make sure you adhere to the general pull request rules outlined in the
  [contributing guide](http://making.teawithstrangers.com/contributing).
