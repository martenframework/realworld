require "./concerns/*"

module Auth
  class SignUpHandler < Marten::Handlers::RecordCreate
    include RequireAnonymousUser
    include NavBarActiveable

    model User
    schema SignUpSchema
    template_name "auth/sign_up.html"
    success_route_name "blogging:home"
    nav_bar_item :sign_up

    def process_valid_schema
      new_user = nil
      model.transaction do
        new_user = model.new(email: schema.email!)
        new_user.set_password(schema.password!)
        new_user.save!

        Profiles::Profile.create!(user: new_user, username: schema.username!)
      end

      self.record = new_user

      user = MartenAuth.authenticate(schema.email!, schema.password!)
      MartenAuth.sign_in(request, user.not_nil!)

      redirect(success_url)
    end
  end
end
