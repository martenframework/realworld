module Blogging
  class HomeHandler < Marten::Handlers::Template
    include NavBarActiveable

    nav_bar_item :home
    template_name "blogging/home.html"

    def context
      ctx = super

      following_users = request.user? && request.user!.profile!.followed_users.exists?
      ctx[:following_users] = following_users

      if request.query_params.fetch(:articles, "user") == "user" && following_users
        ctx[:current_tab] = "user"
        ctx[:articles] = paginated_user_feed_articles
      else
        ctx[:current_tab] = "global"
        ctx[:articles] = paginated_global_feed_articles
      end

      ctx
    end

    private PAGE_PARAM = "page"
    private PAGE_SIZE  = 10

    private def page_number
      request.query_params[PAGE_PARAM]?.try(&.to_i) || 1
    rescue ArgumentError
      1
    end

    private def paginated_global_feed_articles
      paginator = Article.order("-created_at").paginator(PAGE_SIZE)
      paginator.page(page_number)
    end

    private def paginated_user_feed_articles
      followed_user_pks = request.user!.profile!.followed_users.pluck(:pk).flatten
      paginator = Article.filter(author_id__in: followed_user_pks).order("-created_at").paginator(PAGE_SIZE)
      paginator.page(page_number)
    end
  end
end
