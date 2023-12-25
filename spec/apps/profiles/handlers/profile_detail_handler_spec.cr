require "./spec_helper"

describe Profiles::ProfileDetailHandler do
  describe "#render_to_response" do
    it "inserts the nav bar item variable if the authenticated user corresponds to the profile" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user)

      handler = Profiles::ProfileDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"username" => user.profile!.username!}
      )

      handler.render_to_response

      handler.context["nav_bar_item"].should eq "profile"
    end

    it "does not insert the nav bar item variable if the authenticated user does not correspond to the profile" do
      user_1 = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      user_2 = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user_1)

      handler = Profiles::ProfileDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"username" => user_2.profile!.username!}
      )

      handler.render_to_response

      handler.context["nav_bar_item"]?.should be_nil
    end

    it "does not insert the nav bar item variable if the user is not authenticated" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")

      handler = Profiles::ProfileDetailHandler.new(
        Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz"),
        Marten::Routing::MatchParameters{"username" => user.profile!.username!}
      )

      handler.render_to_response

      handler.context["nav_bar_item"]?.should be_nil
    end

    it "inserts a boolean indicating that the current user is following the displayed user" do
      user_1 = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      user_2 = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      user_1.profile!.followed_users.add(user_2.profile!)

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user_1)

      handler = Profiles::ProfileDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"username" => user_2.profile!.username!}
      )

      handler.render_to_response

      handler.context["following"]?.should be_true
    end

    it "inserts a boolean indicating that the current user is not following the displayed user" do
      user_1 = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      user_2 = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user_1)

      handler = Profiles::ProfileDetailHandler.new(
        request,
        Marten::Routing::MatchParameters{"username" => user_2.profile!.username!}
      )

      handler.render_to_response

      handler.context["following"]?.should be_false
    end

    it "inserts the first page of authored articles when no articles query parameter is specified" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      15.times do |i|
        Blogging::Article.create!(
          title: "Article #{i}",
          slug: "article-#{i}",
          description: "My article description",
          body: "# Hello World",
          author: user.profile!,
        )

        Blogging::Article.create!(
          title: "Other article #{i}",
          slug: "other-article-#{i}",
          description: "My article description",
          body: "# Hello World",
          author: other_user.profile!,
        )
      end

      handler = Profiles::ProfileDetailHandler.new(
        Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz"),
        Marten::Routing::MatchParameters{"username" => user.profile!.username!}
      )

      handler.render_to_response

      handler.context["current_tab"].should eq "authored_articles"

      page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
      page.size.should eq 10
      page.each do |article|
        article.author.should eq user.profile!
      end
    end

    it "inserts the right page when the articles query parameter is set to autored and no page is set" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      15.times do |i|
        Timecop.freeze(i.days.ago) do
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: user.profile!,
          )

          Blogging::Article.create!(
            title: "Other article #{i}",
            slug: "other-article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end
      end

      handler = Profiles::ProfileDetailHandler.new(
        Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=authored"),
        Marten::Routing::MatchParameters{"username" => user.profile!.username!}
      )

      handler.render_to_response

      handler.context["current_tab"].should eq "authored_articles"

      page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
      page.size.should eq 10
      page.map(&.title).should eq (0..9).map { |i| "Article #{i}" }
    end

    it "inserts the right page when the articles query parameter is set to authored and a page is set" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      15.times do |i|
        Timecop.freeze(i.days.ago) do
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: user.profile!,
          )

          Blogging::Article.create!(
            title: "Other article #{i}",
            slug: "other-article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )
        end
      end

      handler = Profiles::ProfileDetailHandler.new(
        Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=authored&page=2"),
        Marten::Routing::MatchParameters{"username" => user.profile!.username!}
      )

      handler.render_to_response

      handler.context["current_tab"].should eq "authored_articles"

      page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
      page.size.should eq 5
      page.map(&.title).should eq (10..14).map { |i| "Article #{i}" }
    end

    it "inserts the right page when the articles query parameter is set to faborited and no page is set" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      15.times do |i|
        Timecop.freeze(i.days.ago) do
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: user.profile!,
          )

          other_article = Blogging::Article.create!(
            title: "Other article #{i}",
            slug: "other-article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )

          user.profile!.favorite_articles.add(other_article)
        end
      end

      handler = Profiles::ProfileDetailHandler.new(
        Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=favorited"),
        Marten::Routing::MatchParameters{"username" => user.profile!.username!}
      )

      handler.render_to_response

      handler.context["current_tab"].should eq "favorited_articles"

      page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
      page.size.should eq 10
      page.map(&.title).should eq (0..9).map { |i| "Other article #{i}" }
    end

    it "inserts the right page when the articles query parameter is set to faborited and a page is set" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      15.times do |i|
        Timecop.freeze(i.days.ago) do
          Blogging::Article.create!(
            title: "Article #{i}",
            slug: "article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: user.profile!,
          )

          other_article = Blogging::Article.create!(
            title: "Other article #{i}",
            slug: "other-article-#{i}",
            description: "My article description",
            body: "# Hello World",
            author: other_user.profile!,
          )

          user.profile!.favorite_articles.add(other_article)
        end
      end

      handler = Profiles::ProfileDetailHandler.new(
        Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz?articles=favorited&page=2"),
        Marten::Routing::MatchParameters{"username" => user.profile!.username!}
      )

      handler.render_to_response

      handler.context["current_tab"].should eq "favorited_articles"

      page = handler.context["articles"].raw.as(Marten::DB::Query::Page(Blogging::Article))
      page.size.should eq 5
      page.map(&.title).should eq (10..14).map { |i| "Other article #{i}" }
    end
  end

  describe "#dispatch" do
    it "performs a Profile lookup based on the username specified in the route parameters" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      response = Marten::Spec.client.get(Marten.routes.reverse("profiles:profile_detail", username: "test"))

      response.status.should eq 200
      response.content.includes?(user.profile!.username!).should be_true
    end
  end
end
