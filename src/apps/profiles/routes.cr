module Profiles
  ROUTES = Marten::Routing::Map.draw do
    path "/@<username:str>", ProfileDetailHandler, name: "profile_detail"
    path "/settings", SettingsUpdateHandler, name: "settings_update"
  end
end
