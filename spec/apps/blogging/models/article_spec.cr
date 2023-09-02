require "./spec_helper"

describe Blogging::Article do
  describe "#rendered_body" do
    it "returns nil if no body is set on the article" do
      article = Blogging::Article.new

      article.rendered_body.should be_nil
    end

    it "returns the body rendered using Markdown" do
      article = Blogging::Article.new(body: "# Hello World")

      article.rendered_body.should eq "<h1>Hello World</h1>\n"
    end
  end
end
