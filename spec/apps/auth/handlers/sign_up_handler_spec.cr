require "./spec_helper"

describe Auth::SignUpHandler do
  describe "#get" do
    it "redirects to the profile page if the user is already authenticated" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      url = Marten.routes.reverse("auth:sign_up")

      Marten::Spec.client.sign_in(user)
      response = Marten::Spec.client.get(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")
    end

    it "renders the form as expected for anonymous users" do
      url = Marten.routes.reverse("auth:sign_up")
      response = Marten::Spec.client.get(url)

      response.status.should eq 200
      response.content.includes?("Sign up").should be_true
    end
  end

  describe "#post" do
    it "renders the form if the form data is invalid" do
      url = Marten.routes.reverse("auth:sign_up")
      response = Marten::Spec.client.post(url, data: {"username": "", "email": "", "password": ""})

      response.status.should eq 422
      response.content.includes?("Sign up").should be_true
    end

    it "signs in the new user and redirects as expected if the is valid" do
      url = Marten.routes.reverse("auth:sign_up")
      response = Marten::Spec.client.post(
        url,
        data: {"username": "test", "email": "test@example.com", "password": "insecure"}
      )

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")
      Marten::Spec.client.get(Marten.routes.reverse("blogging:home")).status.should eq 200
    end
  end
end
