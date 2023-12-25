module Profiles
  class ProfileDetailHandler < Marten::Handlers::RecordDetail
    model Profile
    lookup_field :username
    record_context_name :profile
    template_name "profiles/profile_detail.html"

    before_render :add_user_data_to_context
    before_render :add_articles_to_context

    private PAGE_PARAM = "page"
    private PAGE_SIZE  = 10

    private def add_articles_to_context
      if request.query_params[:articles]? == "favorited"
        context[:current_tab] = "favorited_articles"
        context[:articles] = paginated_favorited_articles
      else
        context[:current_tab] = "authored_articles"
        context[:articles] = paginated_authored_articles
      end
    end

    private def add_user_data_to_context
      if request.user.try(&.profile) == record
        context[:nav_bar_item] = "profile"
      elsif request.user?
        context[:following] = request.user!.profile!.followed_users.exists?(pk: record.pk)
      end
    end

    private def page_number
      request.query_params[PAGE_PARAM]?.try(&.to_i) || 1
    rescue ArgumentError
      1
    end

    private def paginated_authored_articles
      paginator = record.articles.order("-created_at").paginator(PAGE_SIZE)
      paginator.page(page_number)
    end

    private def paginated_favorited_articles
      paginator = record.favorite_articles.order("-created_at").paginator(PAGE_SIZE)
      paginator.page(page_number)
    end
  end
end
