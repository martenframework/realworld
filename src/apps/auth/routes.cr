module Auth
  ROUTES = Marten::Routing::Map.draw do
    path "/signup", SignUpHandler, name: "sign_up"
    path "/signin", SignInHandler, name: "sign_in"
    path "/signout", SignOutHandler, name: "sign_out"
  end
end
