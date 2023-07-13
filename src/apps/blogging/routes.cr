module Blogging
  ROUTES = Marten::Routing::Map.draw do
    path "/", HomeHandler, name: "home"
  end
end
