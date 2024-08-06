# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

puts "creating user"
user = User.find_by(
  email: "test@user.com"
)

unless user.nil?
  puts "user already exists"
else
  user = User.create(
    fname: "test",
    lname: "user",
    email: "test@user.com",
    password: "Password12!"
  )

  Api::V1::CreateBucketService.new(user.bucket_token).perform

  puts "created user"
end
