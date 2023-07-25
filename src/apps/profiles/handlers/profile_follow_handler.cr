module Profiles
  class ProfileFollowHandler < Marten::Handler
    include Auth::RequireSignedInUser

    http_method_names :post

    def post
      profile = Profile.get!(username: params["username"]?)
      return head 400 if request.user!.profile == profile

      if request.user!.profile!.followed_users.exists?(pk: profile.pk)
        request.user!.profile!.followed_users.remove(profile)
        following = false
      else
        request.user!.profile!.followed_users.add(profile)
        following = true
      end

      json({"following" => following})
    end
  end
end
