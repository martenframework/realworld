module Blogging
  ROUTES = Marten::Routing::Map.draw do
    path "/", HomeHandler, name: "home"
    path "/post", ArticleCreateHandler, name: "article_create"
    path "/article/<slug:slug>", ArticleDetailHandler, name: "article_detail"
    path "/article/<slug:slug>/edit", ArticleUpdateHandler, name: "article_update"
  end
end
