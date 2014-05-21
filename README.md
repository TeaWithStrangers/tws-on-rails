# TWS

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
```

# Environment Var Setup

We use [Figaro][1] for configuring our environment variables.

You'll want to run `rails g figaro:install` and then add the following variables
to your `config/application.yml` to get email working:

* `GMAIL_USERNAME`: The username you use to log into GMail, domain included
  (e.g. `gmail.com`)
* `GMAIL_PASSWORD`: The password you use to log into GMail, domain included

# Creating Roles

You'll also need to create the Roles used by Cancan (while we wait to get a
proper fixture setup going for dev). 

In the Rails console:

```
=> %w{Admin Host}.map {|r| Role.create(name: r) }
```

[1]:https://github.com/laserlemon/figaro
