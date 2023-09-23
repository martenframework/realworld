module Blogging
  class ArticleDeleteHandler < Marten::Handler
    include Auth::RequireSignedInUser

    @article : Blogging::Article? = nil

    before_dispatch :require_signed_in_author

    def post
      article.delete

      redirect reverse("blogging:home")
    end

    private def article : Blogging::Article
      @article ||= Article.get!(slug: params[:slug])
    end

    private def require_signed_in_author
      raise Marten::HTTP::Errors::PermissionDenied.new if request.user!.profile != article.author
    end
  end
end
