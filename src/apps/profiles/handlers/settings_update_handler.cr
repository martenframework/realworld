module Profiles
  class SettingsUpdateHandler < Marten::Handlers::Schema
    include Auth::RequireSignedInUser
    include NavBarActiveable

    @schema : SettingsUpdateSchema?

    template_name "profiles/settings_update.html"
    success_route_name "blogging:home"
    nav_bar_item :settings

    def initial_data
      Marten::Schema::DataHash{
        "email"     => request.user!.email,
        "username"  => request.user!.profile!.username,
        "image_url" => request.user!.profile!.image_url,
        "bio"       => request.user!.profile!.bio,
      }
    end

    def process_valid_schema
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

      super
    end

    def schema
      @schema ||= SettingsUpdateSchema.new(request.data, initial_data).tap do |s|
        s.current_profile = request.user!.profile
      end
    end
  end
end
