module Blogging
  class ArticleDetailHandler < Marten::Handlers::RecordDetail
    model Article
    template_name "blogging/article_detail.html"
    lookup_field :slug
    record_context_name :article

    before_render :add_user_data_to_context
    before_render :add_paginated_comments_to_context

    private COMMENT_PAGE_PARAM = "comment_page"
    private COMMENT_PAGE_SIZE  = 10

    private def add_paginated_comments_to_context
      context[:comments] = paginated_comments
    end

    private def add_user_data_to_context
      if request.user? && record.author != request.user!.profile
        context[:following] = request.user!.profile!.followed_users.exists?(pk: record.author_id)
      end

      if request.user?
        context[:favorited] = request.user!.profile!.favorite_articles.exists?(pk: record.pk)
      end
    end

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
