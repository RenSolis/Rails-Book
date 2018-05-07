User.create!(name: "Renzo Solis", email: "rensoliscastillo@gmail.com", password: "putamare", password_confirmation: "putamare", admin: true, activated: true, activated_at: Time.zone.now)
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name: name, email: email, password: password, password_confirmation: password, activated: true, activated_at: Time.zone.now)
end
