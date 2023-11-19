module Blogging
  class CommentDeleteHandler < Marten::Handler
    include Auth::RequireSignedInUser

    @article : Blogging::Article? = nil
    @comment : Blogging::Comment? = nil

    before_dispatch :require_signed_in_author

    def post
      comment.delete

      redirect reverse("blogging:article_detail", slug: article.slug!)
    end

    private def article : Blogging::Article
      @article ||= Article.get!(slug: params[:slug])
    end

    private def comment : Blogging::Comment
      @comment ||= article.comments.get!(id: params[:comment_id])
    end

    private def require_signed_in_author
      raise Marten::HTTP::Errors::PermissionDenied.new if request.user!.profile != comment.author
    end
  end
end
