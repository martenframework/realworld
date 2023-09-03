require "./spec_helper"

describe NavBarActiveable do
  describe "#nav_bar_item(item)" do
    it "allows to set the nav bar item associated with the handler from a string value" do
      NavBarActiveableSpec::TestWithStringHandler.nav_bar_item.should eq "home"
    end

    it "allows to set the nav bar item associated with the handler from a symbol value" do
      NavBarActiveableSpec::TestWithSymbolHandler.nav_bar_item.should eq "home"
    end
  end

  describe "#context" do
    it "adds the configured nav bar item to the context" do
      request = Marten::HTTP::Request.new(method: "GET", resource: "/test/xyz")
      handler = NavBarActiveableSpec::TestWithStringHandler.new(request)

      handler.context["nav_bar_item"].should eq "home"
    end
  end
end

module NavBarActiveableSpec
  class TestWithStringHandler < Marten::Handlers::Template
    include NavBarActiveable

    nav_bar_item "home"
  end

  class TestWithSymbolHandler < Marten::Handlers::Template
    include NavBarActiveable

    nav_bar_item :home
  end
end
