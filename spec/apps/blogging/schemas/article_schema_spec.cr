require "./spec_helper"

describe Blogging::ArticleSchema do
  describe "#slugified_title" do
    it "returns a slugified version of the title" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
        }
      )

      schema.valid?

      schema.slugified_title.starts_with?("my-article-").should be_true
    end

    it "raises NilAssertionError if no title is specified" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "description" => "My super article",
          "body"        => "My super article body",
        }
      )

      expect_raises(NilAssertionError) do
        schema.slugified_title
      end
    end
  end

  describe "#tags_array" do
    it "returns an empty array if no tags are specified" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
        }
      )

      schema.valid?

      schema.tags_array.should be_empty
    end

    it "returns the stripped tags" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
          "tags"        => ["tag1", "tag2", "tag3", " thistag   "].join(","),
        }
      )

      schema.valid?

      schema.tags_array.should eq ["tag1", "tag2", "tag3", "thistag"]
    end

    it "returns unique tags" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
          "tags"        => ["tag1", "tag2", "tag1", "tag3", " thistag   "].join(","),
        }
      )

      schema.valid?

      schema.tags_array.should eq ["tag1", "tag2", "tag3", "thistag"]
    end
  end

  describe "#valid?" do
    it "validates an article without tags" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
        }
      )

      schema.valid?.should be_true
    end

    it "validates an article without tags when the tags field is nil" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
          "tags"        => nil,
        }
      )

      schema.valid?.should be_true
    end

    it "validates an article without tags when tags field is empty" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
          "tags"        => "",
        }
      )

      schema.valid?.should be_true
    end

    it "validates an article with tags" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
          "tags"        => "tag1,tag2",
        }
      )

      schema.valid?.should be_true
    end

    it "does not validate an article with too many tags" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
          "tags"        => ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6"].join(","),
        }
      )

      schema.valid?.should be_false
      schema.errors.size.should eq 1
      schema.errors[0].field.should eq "tags"
      schema.errors[0].message.should eq "Too many tags specified"
    end

    it "does not validate an article with invalid tag values" do
      schema = Blogging::ArticleSchema.new(
        Marten::Schema::DataHash{
          "title"       => "My article",
          "description" => "My super article",
          "body"        => "My super article body",
          "tags"        => ["tag1", " this is not a tag ", "//@ test", "tag4"].join(","),
        }
      )

      schema.valid?.should be_false
      schema.errors.size.should eq 2
      schema.errors[0].field.should eq "tags"
      schema.errors[0].message.should eq "Invalid tag specified: this is not a tag"
      schema.errors[1].field.should eq "tags"
      schema.errors[1].message.should eq "Invalid tag specified: //@ test"
    end
  end
end
