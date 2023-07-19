module Profiles
  class ProfileDetailHandler < Marten::Handlers::RecordDetail
    model Profile
    lookup_field :username
    record_context_name :profile
    template_name "profiles/profile_detail.html"

    def context
      ctx = super
      ctx["nav_bar_item"] = "profile" if request.user.try(&.profile) == record
      ctx
    end
  end
end
