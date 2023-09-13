require "./spec_helper"

describe Blogging::ArticleDeleteHandler do
  describe "#post" do
    it "redirects to the sign in page if the user is not authenticated" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      url = Marten.routes.reverse("blogging:article_delete", slug: article.slug!)

      response = Marten::Spec.client.post(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")
    end

    it "raises a permission denied exception if the signed in user is not the author of the article" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")
      Marten::Spec.client.sign_in(other_user)

      url = Marten.routes.reverse("blogging:article_delete", slug: article.slug!)

      expect_raises(Marten::HTTP::Errors::PermissionDenied) do
        Marten::Spec.client.get(url)
      end
    end

    it "deletes the considered article and redirects to the home page if the signed in user is the author" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("blogging:article_delete", slug: article.slug!)

      response = Marten::Spec.client.post(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")

      expect_raises(Marten::DB::Errors::RecordNotFound) do
        Blogging::Article.get!(id: article.id)
      end
    end
  end
end
