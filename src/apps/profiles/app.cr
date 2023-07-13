require "./handlers/**"
require "./models/**"
require "./routes"
require "./schemas/**"

module Profiles
  class App < Marten::App
    label :profiles
  end
end
