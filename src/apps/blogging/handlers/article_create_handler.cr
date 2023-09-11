module Blogging
  class ArticleCreateHandler < Marten::Handlers::Schema
    include Auth::RequireSignedInUser
    include NavBarActiveable

    schema ArticleSchema
    template_name "blogging/article_create_update.html"

    after_successful_schema_validation :create_article_and_redirect

    nav_bar_item :article_create

    private def create_article_and_redirect
      article = nil

      Article.transaction do
        article = Article.create!(
          title: schema.title!,
          slug: schema.slugified_title,
          description: schema.description!,
          body: schema.body!,
          author: request.user!.profile,
        )

        tags = schema.tags_array.map do |tag|
          Tag.get_or_create!(label: tag)
        end

        article.tags.add(tags)

        nil
      end

      redirect reverse("blogging:article_detail", slug: article.not_nil!.slug!)
    end
  end
end
