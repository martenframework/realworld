module Profiles
  class SettingsUpdateHandler < Marten::Handlers::Schema
    include Auth::RequireSignedInUser
    include NavBarActiveable

    schema SettingsUpdateSchema
    template_name "profiles/settings_update.html"
    success_route_name "blogging:home"
    nav_bar_item :settings

    before_schema_validation :assign_current_profile_to_schema
    after_successful_schema_validation :update_user_and_profile

    def initial_data
      Marten::Schema::DataHash{
        "email"     => request.user!.email,
        "username"  => request.user!.profile!.username,
        "image_url" => request.user!.profile!.image_url,
        "bio"       => request.user!.profile!.bio,
      }
    end

    private def assign_current_profile_to_schema
      schema.current_profile = request.user!.profile
    end

    private def update_user_and_profile
      request.user!.transaction do
        request.user!.email = schema.email!
        request.user!.set_password(schema.password!) if schema.password?
        request.user!.save!

        request.user!.profile!.update!(
          username: schema.username!,
          image_url: schema.image_url,
          bio: schema.bio,
        )
      end

      if schema.password?
        MartenAuth.update_session_auth_hash(request, request.user!)
      end
    end
  end
end
