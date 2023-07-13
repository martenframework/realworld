require "./spec_helper"

describe Auth::SignOutHandler do
  describe "#get" do
    it "redirects to the sign in page if the user is not authenticated" do
      url = Marten.routes.reverse("auth:sign_out")

      response = Marten::Spec.client.get(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")
    end

    it "signs out any authenticated user as expected" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      url = Marten.routes.reverse("auth:sign_out")

      Marten::Spec.client.sign_in(user)
      response = Marten::Spec.client.get(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")
    end
  end

  describe "#post" do
    it "signs out any authenticated user as expected" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      url = Marten.routes.reverse("auth:sign_out")

      Marten::Spec.client.sign_in(user)
      response = Marten::Spec.client.post(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")
    end
  end
end
