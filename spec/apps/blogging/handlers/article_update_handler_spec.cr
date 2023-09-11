require "./spec_helper"

describe Blogging::ArticleCreateHandler do
  describe "#get" do
    it "redirects to the sign in page if the user is not authenticated" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      url = Marten.routes.reverse("blogging:article_update", slug: article.slug!)

      response = Marten::Spec.client.get(url)

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

      url = Marten.routes.reverse("blogging:article_update", slug: article.slug!)

      expect_raises(Marten::HTTP::Errors::PermissionDenied) do
        Marten::Spec.client.get(url)
      end
    end

    it "renders the form if the right user is authenticated" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("blogging:article_update", slug: article.slug!)

      response = Marten::Spec.client.get(url)

      response.status.should eq 200
      response.content.includes?("Publish Article").should be_true
    end

    it "raises a not found exception if the article is not found" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")

      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("blogging:article_update", slug: "unknown-article")

      expect_raises(Marten::DB::Errors::RecordNotFound) do
        Marten::Spec.client.get(url)
      end
    end
  end

  describe "#post" do
    it "can update an article without tags" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      url = Marten.routes.reverse("blogging:article_update", slug: article.slug!)

      response = Marten::Spec.client.post(
        url,
        data: {
          "title"       => "My updated article",
          "description" => "My updated super article",
          "body"        => "My updated super article body",
        }
      )

      article = Blogging::Article.get!(id: article.id)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: article.slug!)

      article.title.should eq "My updated article"
      article.description.should eq "My updated super article"
      article.body.should eq "My updated super article body"
      article.slug!.starts_with?("my-updated-article-").should be_true
      article.tags.exists?.should be_false
    end

    it "can update an article with tags by changing its tags" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )
      article.tags.add(Blogging::Tag.create!(label: "foo"))
      article.tags.add(Blogging::Tag.create!(label: "bar"))

      url = Marten.routes.reverse("blogging:article_update", slug: article.slug!)

      response = Marten::Spec.client.post(
        url,
        data: {
          "title"       => "My updated article",
          "description" => "My updated super article",
          "body"        => "My updated super article body",
          "tags"        => "bar,baz",
        }
      )

      article = Blogging::Article.get!(id: article.id)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: article.slug!)

      article.title.should eq "My updated article"
      article.description.should eq "My updated super article"
      article.body.should eq "My updated super article body"
      article.slug!.starts_with?("my-updated-article-").should be_true
      article.tags.exists?.should be_true
      article.tags.order(:label).map(&.label).should eq ["bar", "baz"]
    end

    it "can update an article with tags that do not change" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )
      article.tags.add(Blogging::Tag.create!(label: "foo"))
      article.tags.add(Blogging::Tag.create!(label: "bar"))

      url = Marten.routes.reverse("blogging:article_update", slug: article.slug!)

      response = Marten::Spec.client.post(
        url,
        data: {
          "title"       => "My updated article",
          "description" => "My updated super article",
          "body"        => "My updated super article body",
          "tags"        => "foo,bar",
        }
      )

      article = Blogging::Article.get!(id: article.id)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: article.slug!)

      article.title.should eq "My updated article"
      article.description.should eq "My updated super article"
      article.body.should eq "My updated super article body"
      article.slug!.starts_with?("my-updated-article-").should be_true
      article.tags.exists?.should be_true
      article.tags.order(:label).map(&.label).should eq ["bar", "foo"]
    end

    it "can update an article with tags that are added" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      url = Marten.routes.reverse("blogging:article_update", slug: article.slug!)

      response = Marten::Spec.client.post(
        url,
        data: {
          "title"       => "My updated article",
          "description" => "My updated super article",
          "body"        => "My updated super article body",
          "tags"        => "foo,bar",
        }
      )

      article = Blogging::Article.get!(id: article.id)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: article.slug!)

      article.title.should eq "My updated article"
      article.description.should eq "My updated super article"
      article.body.should eq "My updated super article body"
      article.slug!.starts_with?("my-updated-article-").should be_true
      article.tags.exists?.should be_true
      article.tags.order(:label).map(&.label).should eq ["bar", "foo"]
    end

    it "can update an article with tags that are cleared" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )
      article.tags.add(Blogging::Tag.create!(label: "foo"))
      article.tags.add(Blogging::Tag.create!(label: "bar"))

      url = Marten.routes.reverse("blogging:article_update", slug: article.slug!)

      response = Marten::Spec.client.post(
        url,
        data: {
          "title"       => "My updated article",
          "description" => "My updated super article",
          "body"        => "My updated super article body",
          "tags"        => "",
        }
      )

      article = Blogging::Article.get!(id: article.id)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: article.slug!)

      article.title.should eq "My updated article"
      article.description.should eq "My updated super article"
      article.body.should eq "My updated super article body"
      article.slug!.starts_with?("my-updated-article-").should be_true
      article.tags.exists?.should be_false
    end

    it "does not modify the slug if the title did not change" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      url = Marten.routes.reverse("blogging:article_update", slug: article.slug!)

      response = Marten::Spec.client.post(
        url,
        data: {
          "title"       => "My article",
          "description" => "My updated super article",
          "body"        => "My updated super article body",
        }
      )

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: "my-article")

      article = Blogging::Article.get!(id: article.id)
      article.title.should eq "My article"
      article.slug.should eq "my-article"
    end
  end
end
