# Create a city
puts "Creating a city"
sf = City.create( name: 'San Francisco', city_code: 'SF', timezone: 'Pacific Time (US & Canada)')

# Create a user
puts "Creating users"
user = User.create(
  name: 'Foo Bar',
  email: 'user@tws-int.com',
  password: 'secret1234',
  password_confirmation: 'secret1234',
  home_city_id: sf.id
)

host = User.create(
  name: 'Bar Baz',
  email: 'host@tws-int.com',
  password: 'secret1234',
  password_confirmation: 'secret1234',
  home_city_id: sf.id
)

admin = User.create(
  name: 'Qux Baz',
  email: 'admin@tws-int.com',
  password: 'secret1234',
  password_confirmation: 'secret1234',
  home_city_id: sf.id
)


host.roles << Role.find_by(name: 'Host')
admin.roles << Role.find_by(name: 'Admin')
[host,admin].map(&:save)
