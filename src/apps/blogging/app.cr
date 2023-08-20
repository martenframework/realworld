require "./handlers/**"
require "./models/**"
require "./routes"
require "./schemas/**"

module Blogging
  class App < Marten::App
    label :blogging
  end
end
