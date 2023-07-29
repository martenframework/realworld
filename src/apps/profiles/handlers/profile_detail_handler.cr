module Profiles
  class ProfileDetailHandler < Marten::Handlers::RecordDetail
    model Profile
    lookup_field :username
    record_context_name :profile
    template_name "profiles/profile_detail.html"

    def context
      ctx = super

      if request.user.try(&.profile) == record
        ctx["nav_bar_item"] = "profile"
      elsif request.user?
        ctx["following"] = request.user!.profile!.followed_users.exists?(pk: record.pk)
      end

      ctx
    end
  end
end
