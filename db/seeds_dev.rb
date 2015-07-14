# Create a city
puts "Creating a city"
sf = City.create( name: 'San Francisco', city_code: 'SF', timezone: 'Pacific Time (US & Canada)')
nyc = City.create( name: 'New York City', city_code: 'NYC', timezone: 'Eastern Time (US & Canada)')
chi = City.create( name: 'Chicago', city_code: 'chicago', timezone: 'Central Time (US & Canada)')

# Create a user
puts "Creating users"
user = User.create(
  nickname: 'Foo Bar',
  name: 'Foo Bar',
  email: 'user@tws.com',
  password: 'secret1234',
  password_confirmation: 'secret1234',
  home_city_id: sf.id
)

host_SF2 = User.create(
  nickname: 'SF Baz',
  name: 'SF Baz',
  email: 'host.sf1@tws.com',
  password: 'secret1234',
  password_confirmation: 'secret1234',
  home_city_id: sf.id
)

host_SF1 = User.create(
  nickname: 'SF Boz',
  name: 'SF Boz',
  email: 'host.sf2@tws.com',
  password: 'secret1234',
  password_confirmation: 'secret1234',
  home_city_id: sf.id
)

host_NYC = User.create(
  nickname: 'NYC Biz',
  name: 'NYC Biz',
  email: 'host.nyc@tws.com',
  password: 'secret1234',
  password_confirmation: 'secret1234',
  home_city_id: nyc.id
)

admin = User.create(
  nickname: 'Admin user',
  name: 'Admin user',
  email: 'admin@tws.com',
  password: 'secret1234',
  password_confirmation: 'secret1234',
  home_city_id: sf.id
)

host_NYC.roles << :host
host_SF1.roles << :host
host_SF2.roles << :host
admin.roles    << :admin

[host_NYC, host_SF1, host_SF2, admin].map(&:save)

puts "Creating tea times"
City.all.each do |city|
  5.times do |i|
    if city.hosts.present?
      host = city.hosts.sample
      date = DateTime.now + (5..15).to_a.sample.days
      puts "Creating Tea time for #{city.name} with host #{host.name} on #{date.to_s}"
      TeaTime.create({
        host: host,
        city: city,
        start_time: date,
        duration: 2
      })
    end
  end
end
