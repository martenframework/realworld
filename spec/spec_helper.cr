ENV["MARTEN_ENV"] = "test"

require "spec"
require "timecop"

require "../src/project"
require "marten/spec"
require "marten_auth/spec"

def create_user(username : String, email : String, password : String)
  user = Auth::User.new(email: email)
  user.set_password(password)
  user.save!

  Profiles::Profile.create!(user: user, username: username)

  user
end
