module Blogging
  class Comment < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :body, :text
    field :article, :many_to_one, to: Blogging::Article
    field :author, :many_to_one, to: Profiles::Profile

    with_timestamp_fields
  end
end
