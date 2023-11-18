module Blogging
  class Comment < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :body, :text
    field :article, :many_to_one, to: Blogging::Article, related: :comments
    field :author, :many_to_one, to: Profiles::Profile

    with_timestamp_fields

    def rendered_body
      Cmark.commonmark_to_html(body!) if body?
    end
  end
end
