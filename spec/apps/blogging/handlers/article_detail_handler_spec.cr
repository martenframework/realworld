require "./spec_helper"

describe Blogging::ArticleDetailHandler do
  describe "#context" do
    it "inserts a boolean indicating that the current user follows the author of the article" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      user.profile!.followed_users.add(other_user.profile!)

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: other_user.profile!,
      )

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user)

      handler = Blogging::ArticleDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"slug" => article.slug!}
      )

      handler.context["following"].should be_true
    end

    it "inserts a boolean indicating that the current user does not follow the author of the article" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: other_user.profile!,
      )

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user)

      handler = Blogging::ArticleDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"slug" => article.slug!}
      )

      handler.context["following"].should be_false
    end
  end
end
