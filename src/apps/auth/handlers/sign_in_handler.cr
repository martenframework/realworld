require "./concerns/*"

module Auth
  class SignInHandler < Marten::Handlers::Schema
    include RequireAnonymousUser
    include NavBarActiveable

    schema SignInSchema
    template_name "auth/sign_in.html"
    success_route_name "blogging:home"
    nav_bar_item :sign_in

    def process_valid_schema
      MartenAuth.sign_in(request, schema.user.not_nil!)
      redirect(success_url)
    end
  end
end
