require "./spec_helper"

describe Profiles::ProfileFollowHandler do
  describe "#post" do
    it "cannot be accessed by anonymous users" do
      response = Marten::Spec.client.post(Marten.routes.reverse("profiles:profile_follow", username: "test"))

      response.status.should eq 302
      response.headers["Location"].should eq Marten.routes.reverse("auth:sign_in")
    end

    it "returns a bad request error if the targetted profile is the current user's profile" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      response = Marten::Spec.client.post(Marten.routes.reverse("profiles:profile_follow", username: "test"))

      response.status.should eq 400
    end

    it "adds the current user to the targetted user's list of followers" do
      targetted_user = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      user = create_user(username: "test2", email: "test2@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      response = Marten::Spec.client.post(
        Marten.routes.reverse("profiles:profile_follow", username: targetted_user.profile!.username!)
      )

      response.status.should eq 200
      JSON.parse(response.content).should eq({"following" => true})

      user.profile!.followed_users.includes?(targetted_user.profile!).should be_true
    end

    it "removes the current user from the targetted user's list of followers if they were already following them" do
      targetted_user = create_user(username: "test1", email: "test1@example.com", password: "insecure")

      user = create_user(username: "test2", email: "test2@example.com", password: "insecure")
      user.profile!.followed_users.add(targetted_user.profile!)

      Marten::Spec.client.sign_in(user)

      response = Marten::Spec.client.post(
        Marten.routes.reverse("profiles:profile_follow", username: targetted_user.profile!.username!)
      )

      response.status.should eq 200
      JSON.parse(response.content).should eq({"following" => false})

      user.profile!.followed_users.includes?(targetted_user.profile!).should be_false
      # user.profile!.followed_users.filter(pk: targetted_user.profile!.pk).exists?.should be_false
    end
  end
end
