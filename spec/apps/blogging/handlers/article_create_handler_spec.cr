require "./spec_helper"

describe Blogging::ArticleCreateHandler do
  describe "#get" do
    it "redirects to the sign in page if the user is not authenticated" do
      url = Marten.routes.reverse("blogging:article_create")

      response = Marten::Spec.client.get(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")
    end

    it "renders the form if the user is authenticated" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("blogging:article_create")
      response = Marten::Spec.client.get(url)

      response.status.should eq 200
      response.content.includes?("Publish Article").should be_true
    end
  end

  describe "#post" do
    it "can create a new article without tags" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("blogging:article_create")

      response = Marten::Spec.client.post(
        url,
        data: {
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
        }
      )

      article = Blogging::Article.get!(title: "My article")

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: article.slug!)

      article.description.should eq "My super article"
      article.body.should eq "My super article body"
      article.slug!.starts_with?("my-article-").should be_true
      article.tags.exists?.should be_false
    end

    it "can create a new article with tags" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("blogging:article_create")

      response = Marten::Spec.client.post(
        url,
        data: {
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
          "tags"        => ["tag1", "tag2", "tag3", " thistag   "].join(","),
        }
      )

      article = Blogging::Article.get!(title: "My article")

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: article.slug!)

      article.description.should eq "My super article"
      article.body.should eq "My super article body"
      article.slug!.starts_with?("my-article-").should be_true

      article.tags.exists?.should be_true
      article.tags.order(:label).map(&.label).should eq ["tag1", "tag2", "tag3", "thistag"]
    end
  end
end
