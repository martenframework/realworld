module Blogging
  class CommentCreateHandler < Marten::Handlers::Schema
    include Auth::RequireSignedInUser

    @article : Blogging::Article?

    schema CommentSchema
    http_method_names :post

    before_dispatch :retrieve_article

    after_failed_schema_validation :redirect_to_article
    after_successful_schema_validation :create_article_comment

    private def article!
      @article.not_nil!
    end

    private def create_article_comment
      Blogging::Comment.create!(
        article: article!,
        author: request.user!.profile!,
        body: schema.body!,
      )

      redirect_to_article
    end

    private def redirect_to_article
      redirect reverse("blogging:article_detail", slug: article!.not_nil!.slug!)
    end

    private def retrieve_article
      @article = Blogging::Article.get!(slug: params[:slug]?)
    end
  end
end
