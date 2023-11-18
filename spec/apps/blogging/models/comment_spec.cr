require "./spec_helper"

describe Blogging::Comment do
  describe "#rendered_body" do
    it "returns nil if no body is set on the comment" do
      comment = Blogging::Comment.new

      comment.rendered_body.should be_nil
    end

    it "returns the body rendered using Markdown" do
      comment = Blogging::Comment.new(body: "# Hello World")

      comment.rendered_body.should eq "<h1>Hello World</h1>\n"
    end
  end
end
