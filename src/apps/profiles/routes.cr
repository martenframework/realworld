module Profiles
  ROUTES = Marten::Routing::Map.draw do
    path "/settings", SettingsUpdateHandler, name: "settings_update"
  end
end
