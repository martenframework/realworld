require "./spec_helper"

describe Profiles::SettingsUpdateHandler do
  describe "#get" do
    it "redirects to the sign in page if the user is not authenticated" do
      url = Marten.routes.reverse("profiles:settings_update")

      response = Marten::Spec.client.get(url)

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")
    end

    it "defines the initial form data from the current user" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      user.profile!.update!(
        bio: "This is a bio",
        image_url: "https://example.com/image.png",
      )

      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("profiles:settings_update")
      response = Marten::Spec.client.get(url)

      response.status.should eq 200
      response.content.includes?(user.email!).should be_true
      response.content.includes?(user.profile!.username!).should be_true
      response.content.includes?(user.profile!.bio!).should be_true
      response.content.includes?(user.profile!.image_url!).should be_true
    end
  end

  describe "#post" do
    it "renders the form if the form data is invalid" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("profiles:settings_update")
      response = Marten::Spec.client.post(url, data: {"email" => ""})

      response.status.should eq 200
      response.content.includes?("Your Settings").should be_true
    end

    it "updates the email address if it was updated" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("profiles:settings_update")
      response = Marten::Spec.client.post(url, data: {"email" => "updated@example.com", "username" => "test"})

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")

      user.reload
      user.email.should eq "updated@example.com"
    end

    it "updates the username if it was updated" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("profiles:settings_update")
      response = Marten::Spec.client.post(url, data: {"email" => "test@example.com", "username" => "updated"})

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")

      user.reload
      user.profile!.username.should eq "updated"
    end

    it "updates the profile image URL if it was updated" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("profiles:settings_update")
      response = Marten::Spec.client.post(
        url,
        data: {"email" => "test@example.com", "username" => "test", "image_url" => "https://example.com/test.png"},
      )

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")

      user.reload
      user.profile!.image_url.should eq "https://example.com/test.png"
    end

    it "updates the profile bio if it was updated" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("profiles:settings_update")
      response = Marten::Spec.client.post(
        url,
        data: {"email" => "test@example.com", "username" => "test", "bio" => "This is my bio"},
      )

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")

      user.reload
      user.profile!.bio.should eq "This is my bio"
    end

    it "updates the password if it was updated" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      url = Marten.routes.reverse("profiles:settings_update")
      response = Marten::Spec.client.post(
        url,
        data: {"email" => "test@example.com", "username" => "test", "password" => "updated"}
      )

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("blogging:home")

      user.reload
      user.check_password("updated").should be_true
    end
  end
end
