require "./spec_helper"

describe Auth::SignUpSchema do
  describe "#valid?" do
    it "returns true if the username and email are valid and if the provided passwords are the same" do
      schema = Auth::SignUpSchema.new(
        Marten::HTTP::Params::Data{
          "username" => ["test"],
          "email"    => ["test@example.com"],
          "password" => ["insecure"],
        }
      )
      schema.valid?.should be_true
      schema.errors.should be_empty
    end

    it "returns false if the data is not provided" do
      schema = Auth::SignUpSchema.new(
        Marten::HTTP::Params::Data{"username" => [""], "email" => [""], "password" => [""]}
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 3
      schema.errors[0].field.should eq "username"
      schema.errors[0].type.should eq "required"
      schema.errors[1].field.should eq "email"
      schema.errors[1].type.should eq "required"
      schema.errors[2].field.should eq "password"
      schema.errors[2].type.should eq "required"
    end

    it "returns false if the username is already taken" do
      create_user(username: "test", email: "test@example.com", password: "insecure")

      schema = Auth::SignUpSchema.new(
        Marten::HTTP::Params::Data{
          "username" => ["test"],
          "email"    => ["jd@example.com"],
          "password" => ["insecure"],
        }
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should eq "username"
      schema.errors[0].message.should eq "This username is already taken"
    end

    it "returns false if the email address is already taken" do
      create_user(username: "test", email: "test@example.com", password: "insecure")

      schema = Auth::SignUpSchema.new(
        Marten::HTTP::Params::Data{
          "username" => ["jd"],
          "email"    => ["test@example.com"],
          "password" => ["insecure"],
        }
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should eq "email"
      schema.errors[0].message.should eq "This email address is already taken"
    end

    it "returns false if the username is already taken in a case insensitive way" do
      create_user(username: "test", email: "test@example.com", password: "insecure")

      schema = Auth::SignUpSchema.new(
        Marten::HTTP::Params::Data{
          "username" => ["TesT"],
          "email"    => ["jd@ExamPLE.com"],
          "password" => ["insecure"],
        }
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should eq "username"
      schema.errors[0].message.should eq "This username is already taken"
    end

    it "returns false if the email address is already taken in a case insensitive way" do
      create_user(username: "test", email: "test@example.com", password: "insecure")

      schema = Auth::SignUpSchema.new(
        Marten::HTTP::Params::Data{
          "username" => ["jd"],
          "email"    => ["TesT@ExamPLE.com"],
          "password" => ["insecure"],
        }
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should eq "email"
      schema.errors[0].message.should eq "This email address is already taken"
    end
  end
end
