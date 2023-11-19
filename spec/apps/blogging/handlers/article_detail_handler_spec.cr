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

    it "inserts a boolean indicating that the current user has favorited the considered article" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: other_user.profile!,
      )

      user.profile!.favorite_articles.add(article)

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user)

      handler = Blogging::ArticleDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"slug" => article.slug!}
      )

      handler.context["favorited"].should be_true
    end

    it "inserts a boolean indicating that the current user has not favorited the considered article" do
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

      handler.context["favorited"].should be_false
    end

    it "inserts an empty page of comments if the article has no comments" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user)

      handler = Blogging::ArticleDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"slug" => article.slug!}
      )

      handler.context["comments"].empty?.should be_true
    end

    it "inserts the first page of comments if the article has comments and no page parameter is set" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )
      other_article = Blogging::Article.create!(
        title: "My other article",
        slug: "my-other-article",
        description: "My other-article description",
        body: "# Hello World",
        author: user.profile!,
      )

      15.times do |i|
        Blogging::Comment.create!(
          article: article,
          body: "# Hello World #{i}",
          author: other_user.profile!,
        )

        Blogging::Comment.create!(
          article: other_article,
          body: "# Hello World",
          author: other_user.profile!,
        )
      end

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user)

      handler = Blogging::ArticleDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"slug" => article.slug!}
      )

      handler.context["comments"].empty?.should be_false
      handler.context["comments"].size.should eq 10
      handler.context["comments"].to_a[0].raw.should be_a Blogging::Comment
      handler.context["comments"].to_a.all? { |c| c.raw.as(Blogging::Comment).article == article }.should be_true
    end

    it "inserts the right page of comments if the article has comments and no page parameter is set" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )
      other_article = Blogging::Article.create!(
        title: "My other article",
        slug: "my-other-article",
        description: "My other-article description",
        body: "# Hello World",
        author: user.profile!,
      )

      15.times do |i|
        Blogging::Comment.create!(
          article: article,
          body: "# Hello World #{i}",
          author: other_user.profile!,
        )

        Blogging::Comment.create!(
          article: other_article,
          body: "# Hello World",
          author: other_user.profile!,
        )
      end

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?comment_page=2")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user)

      handler = Blogging::ArticleDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"slug" => article.slug!}
      )

      handler.context["comments"].empty?.should be_false
      handler.context["comments"].size.should eq 5
      handler.context["comments"].to_a[0].raw.should be_a Blogging::Comment
      handler.context["comments"].to_a.all? { |c| c.raw.as(Blogging::Comment).article == article }.should be_true
    end
  end
end
