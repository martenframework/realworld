require "./concerns/*"

module Auth
  class SignOutHandler < Marten::Handler
    include RequireSignedInUser

    def dispatch
      MartenAuth.sign_out(request)
      redirect reverse("blogging:home")
    end
  end
end
