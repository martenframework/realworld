module Profiles
  class ProfileDetailHandler < Marten::Handlers::RecordDetail
    model Profile
    lookup_field :username
    record_context_name :profile
    template_name "profiles/profile_detail.html"

    def context
      ctx = super

      if request.user.try(&.profile) == record
        ctx[:nav_bar_item] = "profile"
      elsif request.user?
        ctx[:following] = request.user!.profile!.followed_users.exists?(pk: record.pk)
      end

      if request.query_params[:articles]? == "favorited"
        ctx[:current_tab] = "favorited_articles"
        ctx[:articles] = paginated_favorited_articles
      else
        ctx[:current_tab] = "authored_articles"
        ctx[:articles] = paginated_authored_articles
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
