module Blogging
  class ArticleDetailHandler < Marten::Handlers::RecordDetail
    model Article
    template_name "blogging/article_detail.html"
    lookup_field :slug
  end
end
