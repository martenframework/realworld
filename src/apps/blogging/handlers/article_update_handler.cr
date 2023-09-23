module Blogging
  class ArticleUpdateHandler < Marten::Handlers::Schema
    include Auth::RequireSignedInUser

    @article : Blogging::Article? = nil

    schema ArticleSchema
    template_name "blogging/article_create_update.html"

    before_dispatch :require_signed_in_author
    after_successful_schema_validation :update_article_and_redirect

    private def article : Blogging::Article
      @article ||= Article.get!(slug: params[:slug])
    end

    private def initial_data
      Marten::Schema::DataHash{
        "title"       => article.title,
        "description" => article.description,
        "body"        => article.body,
        "tags"        => article.tags.map(&.label).join(","),
      }
    end

    private def require_signed_in_author
      raise Marten::HTTP::Errors::PermissionDenied.new if request.user!.profile != article.author
    end

    private def update_article_and_redirect
      Article.transaction do
        if schema.title != article.title
          article.title = schema.title
          article.slug = schema.slugified_title
        end

        article.description = schema.description!
        article.body = schema.body

        article.save!

        tags = schema.tags_array.map do |tag|
          Tag.get_or_create!(label: tag)
        end

        article.tags.clear
        article.tags.add(tags)

        nil
      end

      redirect reverse("blogging:article_detail", slug: article.not_nil!.slug!)
    end
  end
end
