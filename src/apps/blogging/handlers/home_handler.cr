module Blogging
  class HomeHandler < Marten::Handlers::Template
    include NavBarActiveable

    @following_users : Bool?

    nav_bar_item :home
    template_name "blogging/home.html"

    before_render :add_user_data_to_context
    before_render :add_articles_to_context
    before_render :add_popular_tags_to_context
    before_render :add_targeted_tag_to_context

    private PAGE_PARAM = "page"
    private PAGE_SIZE  = 10
    private TAGS_COUNT = 20

    private def add_articles_to_context
      if !targeted_tag.nil?
        context[:current_tab] = "tag"
        context[:articles] = paginated_tag_feed_articles
      elsif request.query_params.fetch(:articles, "user") == "user" && following_users?
        context[:current_tab] = "user"
        context[:articles] = paginated_user_feed_articles
      else
        context[:current_tab] = "global"
        context[:articles] = paginated_global_feed_articles
      end
    end

    private def add_popular_tags_to_context
      context[:tags] = Tag.all[..TAGS_COUNT]
    end

    private def add_targeted_tag_to_context
      context[:targeted_tag] = targeted_tag
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

    private def paginated_tag_feed_articles
      paginator = Article.filter(tags__label: targeted_tag).order("-created_at").paginator(PAGE_SIZE)
      paginator.page(page_number)
    end

    private def paginated_user_feed_articles
      followed_user_pks = request.user!.profile!.followed_users.pluck(:pk).flatten
      paginator = Article.filter(author_id__in: followed_user_pks).order("-created_at").paginator(PAGE_SIZE)
      paginator.page(page_number)
    end

    private def targeted_tag
      request.query_params[:tag]?
    end
  end
end
