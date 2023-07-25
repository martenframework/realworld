module Profiles
  ROUTES = Marten::Routing::Map.draw do
    path "/@<username:str>", ProfileDetailHandler, name: "profile_detail"
    path "/@<username:str>/follow", ProfileFollowHandler, name: "profile_follow"
    path "/settings", SettingsUpdateHandler, name: "settings_update"
  end
end
