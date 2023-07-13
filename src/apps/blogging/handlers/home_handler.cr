module Blogging
  class HomeHandler < Marten::Handlers::Template
    include NavBarActiveable

    nav_bar_item :home
    template_name "blogging/home.html"
  end
end
