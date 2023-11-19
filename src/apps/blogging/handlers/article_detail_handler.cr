module Blogging
  class ArticleDetailHandler < Marten::Handlers::RecordDetail
    model Article
    template_name "blogging/article_detail.html"
    lookup_field :slug
    record_context_name :article

    def context
      ctx = super

      if request.user? && record.author != request.user!.profile
        ctx[:following] = request.user!.profile!.followed_users.exists?(pk: record.author_id)
      end

      if request.user?
        ctx[:favorited] = request.user!.profile!.favorite_articles.exists?(pk: record.pk)
      end

      ctx[:comments] = paginated_comments

      ctx
    end

    private COMMENT_PAGE_PARAM = "comment_page"
    private COMMENT_PAGE_SIZE  = 10

    private def comment_page_number
      request.query_params[COMMENT_PAGE_PARAM]?.try(&.to_i) || 1
    rescue ArgumentError
      1
    end

    private def paginated_comments
      paginator = record.comments.order("-created_at").paginator(COMMENT_PAGE_SIZE)
      paginator.page(comment_page_number)
    end
  end
end
