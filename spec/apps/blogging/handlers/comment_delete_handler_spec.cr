require "./spec_helper"

describe Blogging::CommentDeleteHandler do
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
      comment = article.comments.create!(article: article, body: "My super comment", author: user.profile!)

      response = Marten::Spec.client.post(
        Marten.routes.reverse("blogging:comment_delete", slug: article.slug!, comment_id: comment.id!),
      )

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")

      comment.reload.persisted?.should be_true
    end

    it "deletes the targeted comment and redirects to the article page" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )
      comment = article.comments.create!(article: article, body: "My super comment", author: user.profile!)

      response = Marten::Spec.client.post(
        Marten.routes.reverse("blogging:comment_delete", slug: article.slug!, comment_id: comment.id!),
      )

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:article_detail", slug: article.slug!)

      expect_raises(Marten::DB::Errors::RecordNotFound) do
        comment.reload
      end
    end

    it "raises a not found error if the article is not found" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )
      comment = Blogging::Comment.create!(article: article, body: "My super comment", author: user.profile!)

      Marten::Spec.client.sign_in(user)

      expect_raises(Marten::DB::Errors::RecordNotFound) do
        Marten::Spec.client.post(
          Marten.routes.reverse("blogging:comment_delete", slug: "not-found", comment_id: comment.id!),
          data: {"body" => "My super comment"}
        )
      end
    end

    it "raises a not found error if the comment is not found" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )

      Marten::Spec.client.sign_in(user)

      expect_raises(Marten::DB::Errors::RecordNotFound) do
        Marten::Spec.client.post(
          Marten.routes.reverse("blogging:comment_delete", slug: article.slug!, comment_id: 0),
          data: {"body" => "My super comment"}
        )
      end
    end

    it "raises a permission denied error if the comment was created by another user" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      other_user = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      article = Blogging::Article.create!(
        title: "My article",
        slug: "my-article",
        description: "My article description",
        body: "# Hello World",
        author: user.profile!,
      )
      comment = Blogging::Comment.create!(article: article, body: "My super comment", author: other_user.profile!)

      Marten::Spec.client.sign_in(user)

      expect_raises(Marten::HTTP::Errors::PermissionDenied) do
        Marten::Spec.client.post(
          Marten.routes.reverse("blogging:comment_delete", slug: article.slug!, comment_id: comment.id!),
          data: {"body" => "My super comment"}
        )
      end
    end
  end
end
