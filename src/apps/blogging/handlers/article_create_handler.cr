module Blogging
  class ArticleCreateHandler < Marten::Handlers::Schema
    include Auth::RequireSignedInUser
    include NavBarActiveable

    schema ArticleCreateSchema
    template_name "blogging/article_create.html"

    after_successful_schema_validation :create_article_and_redirect

    nav_bar_item :article_create

    private def create_article_and_redirect
      article = nil

      Article.transaction do
        article = Article.create!(
          title: schema.title!,
          slug: slugify(schema.title!),
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

    private def slugify(title)
      suffix = "-#{Random::Secure.hex(4)}"

      slug = title.gsub(/[^\w\s-]/, "").downcase
      slug = slug.gsub(/[-\s]+/, "-").strip("-_")
      slug = slug.unicode_normalize(:nfkc)
      slug = String.new(slug.encode("ascii", :skip))

      slug[...(50 - suffix.size)] + suffix
    end
  end
end
