module Blogging
  class CommentSchema < Marten::Schema
    field :body, :string, max_size: 50_000
  end
end
