require "./spec_helper"

describe Blogging::CommentCreateHandler do
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

      response = Marten::Spec.client.post(
        Marten.routes.reverse("blogging:comment_create", slug: article.slug!),
        data: {"body" => "My super comment"}
      )

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")

      article.reload.comments.size.should eq 0
    end

    it "creates a new article comment if the user is authenticated" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: other_user.profile!,
      )

      response = Marten::Spec.client.post(
        Marten.routes.reverse("blogging:comment_create", slug: article.slug!),
        data: {"body" => "My super comment"}
      )

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: article.slug!)

      article.reload.comments.size.should eq 1
      article.comments.first!.body.should eq "My super comment"
      article.comments.first!.author.should eq user.profile!
    end

    it "raises a not found error if the article is not found" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      expect_raises(Marten::DB::Errors::RecordNotFound) do
        Marten::Spec.client.post(
          Marten.routes.reverse("blogging:comment_create", slug: "not-found"),
          data: {"body" => "My super comment"}
        )
      end
    end
  end
end
