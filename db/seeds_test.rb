puts "Deleting all old test records"
[City, User, Role, Attendance, TeaTime].each do |c|
  c.delete_all
end

['Host', 'Admin'].each do |n|
  Role.create(name: n)
end
