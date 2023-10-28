require "./spec_helper"

describe Blogging::HomeHandler do
  describe "#context" do
    context "with an anonymous user" do
      it "inserts a boolean indicating that no user is followed" do
        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["following_users"].should be_false
      end

      it "inserts the first page of global articles when no articles query param is set" do
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "global"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 10
        page.each do |article|
          article.author.should eq other_user.profile!
        end
      end

      it "inserts the right page of global articles when no articles query param is set and a page is set" do
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?page=2")

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "global"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 5
        page.each do |article|
          article.author.should eq other_user.profile!
        end
      end

      it "inserts the first page of global articles when the articles query param is set to global" do
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=global")

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "global"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 10
        page.each do |article|
          article.author.should eq other_user.profile!
        end
      end

      it "inserts the right page of global articles when the articles param is global and a page is set" do
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=global&page=2")

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "global"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 5
        page.each do |article|
          article.author.should eq other_user.profile!
        end
      end

      it "fallbacks to the first page of global articles when the articles query param is set to user" do
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=user")

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "global"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 10
        page.each do |article|
          article.author.should eq other_user.profile!
        end
      end
    end

    context "with an authenticated user" do
      it "inserts a boolean indicating that at least one user is followed" do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        user.profile!.followed_users.add(other_user.profile!)

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["following_users"].should be_true
      end

      it "inserts a boolean indicating that no user is followed" do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["following_users"].should be_false
      end

      it "inserts the first page of articles from followed users when no articles query param is specified" do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
        other_user_1 = create_user(username: "test2", email: "test2@example.com", password: "insecure")
        other_user_2 = create_user(username: "test3", email: "test3@example.com", password: "insecure")

        user.profile!.followed_users.add(other_user_1.profile!)

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user_1.profile!,
          )

          Blogging::Article.create!(
            title: "Other article #{i}",
            slug: "other-article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user_2.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "user"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 10
        page.each do |article|
          article.author.should eq other_user_1.profile!
        end
      end

      it "inserts the right page of articles from followed users when no articles param is set and a page is set" do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
        other_user_1 = create_user(username: "test2", email: "test2@example.com", password: "insecure")
        other_user_2 = create_user(username: "test3", email: "test3@example.com", password: "insecure")

        user.profile!.followed_users.add(other_user_1.profile!)

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user_1.profile!,
          )

          Blogging::Article.create!(
            title: "Other article #{i}",
            slug: "other-article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user_2.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?page=2")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "user"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 5
        page.each do |article|
          article.author.should eq other_user_1.profile!
        end
      end

      it "inserts the first page of articles from followed users when the articles query param is set to user" do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
        other_user_1 = create_user(username: "test2", email: "test2@example.com", password: "insecure")
        other_user_2 = create_user(username: "test3", email: "test3@example.com", password: "insecure")

        user.profile!.followed_users.add(other_user_1.profile!)

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user_1.profile!,
          )

          Blogging::Article.create!(
            title: "Other article #{i}",
            slug: "other-article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user_2.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=user")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "user"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 10
        page.each do |article|
          article.author.should eq other_user_1.profile!
        end
      end

      it "inserts the right page of articles from followed users when the articles param is user and a page is set" do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
        other_user_1 = create_user(username: "test2", email: "test2@example.com", password: "insecure")
        other_user_2 = create_user(username: "test3", email: "test3@example.com", password: "insecure")

        user.profile!.followed_users.add(other_user_1.profile!)

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user_1.profile!,
          )

          Blogging::Article.create!(
            title: "Other article #{i}",
            slug: "other-article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user_2.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=user&page=2")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "user"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 5
        page.each do |article|
          article.author.should eq other_user_1.profile!
        end
      end

      it "inserts the first page of global articles when no articles query param is set and the user follows no one" do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "global"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 10
        page.each do |article|
          article.author.should eq other_user.profile!
        end
      end

      it(
        "inserts the first page of global articles when no articles param is set, the user follows no one, " \
        "and a page is set"
      ) do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?page=2")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "global"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 5
        page.each do |article|
          article.author.should eq other_user.profile!
        end
      end

      it "inserts the first page of global articles when the articles query param is set to global" do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=global")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "global"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 10
        page.each do |article|
          article.author.should eq other_user.profile!
        end
      end

      it "inserts the right page of global articles when the articles param is global and a page is set" do
        user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
        other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

        15.times do |i|
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end

        request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=global&page=2")
        request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
        MartenAuth.sign_in(request, user)

        handler = Blogging::HomeHandler.new(request, Marten::Routing::MatchParameters.new)

        handler.context["current_tab"].should eq "global"

        page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
        page.size.should eq 5
        page.each do |article|
          article.author.should eq other_user.profile!
        end
      end
    end
  end
end
