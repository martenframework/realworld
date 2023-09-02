module Blogging
  class Article < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :slug, :slug
    field :title, :string, max_size: 255
    field :description, :text
    field :body, :text
    field :author, :many_to_one, to: Profiles::Profile
    field :tags, :many_to_many, to: Blogging::Tag

    with_timestamp_fields

    def rendered_body
      Cmark.commonmark_to_html(body!) if body?
    end
  end
end
