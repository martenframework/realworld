require "./concerns/*"

module Auth
  class SignUpHandler < Marten::Handlers::Schema
    include RequireAnonymousUser
    include NavBarActiveable

    schema SignUpSchema
    template_name "auth/sign_up.html"
    success_route_name "blogging:home"
    nav_bar_item :sign_up

    after_successful_schema_validation :sign_up_user

    private def sign_up_user
      new_user = nil
      User.transaction do
        new_user = User.new(email: schema.email!)
        new_user.set_password(schema.password!)
        new_user.save!

        Profiles::Profile.create!(user: new_user, username: schema.username!)
      end

      user = MartenAuth.authenticate(schema.email!, schema.password!)
      MartenAuth.sign_in(request, user.not_nil!)
    end
  end
end
