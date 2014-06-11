# Create a city
puts "Creating a city"
sf = City.create( name: 'San Francisco', city_code: 'SF', timezone: 'Pacific Time (US & Canada)')

# Create a user
puts "Creating a user"
User.create(
  name: 'Foo Bar',
  email: 'admin@admin.com',
  password: 'secret1234',
  password_confirmation: 'secret1234',
  home_city_id: sf.id
)