module Blogging
  ROUTES = Marten::Routing::Map.draw do
    path "/", HomeHandler, name: "home"
    path "/post", ArticleCreateHandler, name: "article_create"
    path "/article/<slug:slug>", ArticleDetailHandler, name: "article_detail"
    path "/article/<slug:slug>/edit", ArticleUpdateHandler, name: "article_update"
    path "/article/<slug:slug>/delete", ArticleDeleteHandler, name: "article_delete"
  end
end
