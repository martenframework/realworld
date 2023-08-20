module Blogging
  class ArticleCreateSchema < Marten::Schema
    field :title, :string, min_size: 10, max_size: 255
    field :description, :string, max_size: 500
    field :body, :string, max_size: 100_000
    field :tags, :string, required: false

    validate :validate_tags

    def tags_array
      return [] of String if tags.nil? || tags!.empty?

      tags!.split(',').map(&.strip).uniq!
    end

    private TAG_LIMIT    =   5
    private TAG_MAX_SIZE = 255
    private TAG_RE       = /\A[a-zA-Z0-9]+\z/

    private def validate_tags
      return if tags.nil?
      return if tags!.empty?

      splitted_tags = tags_array
      errors.add(:tags, "Too many tags specified") if splitted_tags.size > TAG_LIMIT
      splitted_tags.each do |tag|
        errors.add(:tags, "Invalid tag specified: #{tag}") unless tag.matches?(TAG_RE) && tag.size <= TAG_MAX_SIZE
      end
    end
  end
end
