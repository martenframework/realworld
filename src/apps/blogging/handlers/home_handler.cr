module Blogging
  class HomeHandler < Marten::Handlers::Template
    include NavBarActiveable

    @following_users : Bool?

    nav_bar_item :home
    template_name "blogging/home.html"

    before_render :add_user_data_to_context
    before_render :add_articles_to_context

    private PAGE_PARAM = "page"
    private PAGE_SIZE  = 10

    private def add_articles_to_context
      if request.query_params.fetch(:articles, "user") == "user" && following_users?
        context[:current_tab] = "user"
        context[:articles] = paginated_user_feed_articles
      else
        context[:current_tab] = "global"
        context[:articles] = paginated_global_feed_articles
      end
    end

    private def add_user_data_to_context
      context[:following_users] = following_users?
    end

    private def following_users?
      @following_users ||= request.user? && request.user!.profile!.followed_users.exists?
    end

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
