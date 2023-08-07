require "./concerns/*"

module Auth
  class SignInHandler < Marten::Handlers::Schema
    include RequireAnonymousUser
    include NavBarActiveable

    schema SignInSchema
    template_name "auth/sign_in.html"
    success_route_name "blogging:home"
    nav_bar_item :sign_in

    after_successful_schema_validation :sign_in_user

    private def sign_in_user
      MartenAuth.sign_in(request, schema.user.not_nil!)
    end
  end
end
