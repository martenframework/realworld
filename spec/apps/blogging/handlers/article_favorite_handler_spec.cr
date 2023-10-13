require "./spec_helper"

describe Blogging::ArticleFavoriteHandler do
  describe "#post" do
    it "cannot be accessed by anonymous users" do
      response = Marten::Spec.client.post(Marten.routes.reverse("blogging:article_favorite", slug: "test"))

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")
    end

    it "returns a 404 response if the article does not exist" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      expect_raises(Marten::DB::Errors::RecordNotFound) do
        Marten::Spec.client.post(Marten.routes.reverse("blogging:article_favorite", slug: "test"))
      end
    end

    it "adds the article to the profile's list of favorited articles" do
      author = create_user(username: "author", email: "author@example.com", password: "insecure")
      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: author.profile!,
      )

      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      response = Marten::Spec.client.post(Marten.routes.reverse("blogging:article_favorite", slug: article.slug!))

      response.status.should eq 200
      JSON.parse(response.content).should eq({"favorited" => true})

      user.profile!.favorite_articles.includes?(article).should be_true
    end

    it "removes the article from the profile's list of favorited articles if it was already favorited" do
      author = create_user(username: "author", email: "author@example.com", password: "insecure")
      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: author.profile!,
      )

      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      user.profile!.favorite_articles.add(article)
      Marten::Spec.client.sign_in(user)

      response = Marten::Spec.client.post(Marten.routes.reverse("blogging:article_favorite", slug: article.slug!))

      response.status.should eq 200
      JSON.parse(response.content).should eq({"favorited" => false})

      user.profile!.favorite_articles.includes?(article).should be_false
    end
  end
end
