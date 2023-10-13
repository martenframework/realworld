module Blogging
  class ArticleFavoriteHandler < Marten::Handler
    include Auth::RequireSignedInUser

    http_method_names :post

    def post
      article = Blogging::Article.get!(slug: params[:slug]?)

      if request.user!.profile!.favorite_articles.exists?(pk: article.pk)
        request.user!.profile!.favorite_articles.remove(article)
        favorited = false
      else
        request.user!.profile!.favorite_articles.add(article)
        favorited = true
      end

      json({"favorited" => favorited})
    end
  end
end
