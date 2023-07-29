require "./spec_helper"

describe Profiles::ProfileDetailHandler do
  describe "#context" do
    it "inserts the nav bar item variable if the authenticated user corresponds to the profile" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user)

      handler = Profiles::ProfileDetailHandler.new(
        request,
        Hash(String, Marten::Routing::Parameter::Types){"username" => user.profile!.username!}
      )

      handler.context["nav_bar_item"].should eq "profile"
    end

    it "does not insert the nav bar item variable if the authenticated user does not correspond to the profile" do
      user_1 = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      user_2 = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user_1)

      handler = Profiles::ProfileDetailHandler.new(
        request,
        Hash(String, Marten::Routing::Parameter::Types){"username" => user_2.profile!.username!}
      )

      handler.context["nav_bar_item"]?.should be_nil
    end

    it "does not insert the nav bar item variable if the user is not authenticated" do
      user = create_user(username: "test1", email: "test1@example.com", password: "insecure")

      handler = Profiles::ProfileDetailHandler.new(
        Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz"),
        Hash(String, Marten::Routing::Parameter::Types){"username" => user.profile!.username!}
      )

      handler.context["nav_bar_item"]?.should be_nil
    end

    it "inserts a boolean indicating that the current user is following the displayed user" do
      user_1 = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      user_2 = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      user_1.profile!.followed_users.add(user_2.profile!)

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user_1)

      handler = Profiles::ProfileDetailHandler.new(
        request,
        Hash(String, Marten::Routing::Parameter::Types){"username" => user_2.profile!.username!}
      )

      handler.context["following"]?.should be_true
    end

    it "inserts a boolean indicating that the current user is not following the displayed user" do
      user_1 = create_user(username: "test1", email: "test1@example.com", password: "insecure")
      user_2 = create_user(username: "test2", email: "test2@example.com", password: "insecure")

      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      request.session = Marten::HTTP::Session::Store::Cookie.new("sessionkey")
      MartenAuth.sign_in(request, user_1)

      handler = Profiles::ProfileDetailHandler.new(
        request,
        Hash(String, Marten::Routing::Parameter::Types){"username" => user_2.profile!.username!}
      )

      handler.context["following"]?.should be_false
    end
  end

  describe "#dispatch" do
    it "performs a Profile lookup based on the username specified in the route parameters" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")
      Marten::Spec.client.sign_in(user)

      response = Marten::Spec.client.get(Marten.routes.reverse("profiles:profile_detail", username: "test"))

      response.status.should eq 200
      response.content.includes?(user.profile!.username!).should be_true
    end
  end
end
