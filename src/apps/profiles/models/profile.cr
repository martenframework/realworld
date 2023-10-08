module Profiles
  class Profile < Marten::Model
    field :id, :big_int, primary_key: true, auto: true
    field :user, :one_to_one, to: Auth::User, related: :profile
    field :username, :string, max_size: 128, unique: true
    field :bio, :text, blank: true, null: true
    field :image_url, :url, blank: true, null: true
    field :followed_users, :many_to_many, to: self
    field :favorite_articles, :many_to_many, to: Blogging::Article, related: :favorited_by
  end
end
