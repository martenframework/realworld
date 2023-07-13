require "./handlers/**"
require "./models/**"
require "./routes"

module Blogging
  class App < Marten::App
    label :blogging
  end
end
