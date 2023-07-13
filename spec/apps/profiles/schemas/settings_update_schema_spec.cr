require "./spec_helper"

describe Profiles::SettingsUpdateSchema do
  describe "#valid?" do
    it "returns true when the changed username and email are valid" do
      schema = Profiles::SettingsUpdateSchema.new(
        Marten::Schema::DataHash{
          "username" => "test",
          "email"    => "test@example.com",
        }
      )

      schema.valid?.should be_true
      schema.errors.should be_empty
    end

    it "returns true when the changed username and email are valid and correspond to the current profile" do
      user = create_user(username: "test", email: "test@example.com", password: "insecure")

      schema = Profiles::SettingsUpdateSchema.new(
        Marten::Schema::DataHash{
          "username" => "test",
          "email"    => "test@example.com",
        }
      )
      schema.current_profile = user.profile

      schema.valid?.should be_true
      schema.errors.should be_empty
    end

    it "returns false if no data is provided" do
      schema = Profiles::SettingsUpdateSchema.new(
        Marten::Schema::DataHash{
          "username" => nil,
          "email"    => nil,
        }
      )

      schema.valid?.should be_false
      schema.errors.size.should eq 2
      schema.errors[0].field.should eq "username"
      schema.errors[0].type.should eq "required"
      schema.errors[1].field.should eq "email"
      schema.errors[1].type.should eq "required"
    end

    it "returns false if the username is already taken" do
      create_user(username: "test", email: "test@example.com", password: "insecure")

      schema = Profiles::SettingsUpdateSchema.new(
        Marten::Schema::DataHash{
          "username" => "test",
          "email"    => "jd@example.com",
        }
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should eq "username"
      schema.errors[0].message.should eq "This username is already taken"
    end

    it "returns false if the email address is already taken" do
      create_user(username: "test", email: "test@example.com", password: "insecure")

      schema = Profiles::SettingsUpdateSchema.new(
        Marten::Schema::DataHash{
          "username" => "jd",
          "email"    => "test@example.com",
        }
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should eq "email"
      schema.errors[0].message.should eq "This email address is already taken"
    end

    it "returns false if the username is already taken in a case insensitive way" do
      create_user(username: "test", email: "test@example.com", password: "insecure")

      schema = Profiles::SettingsUpdateSchema.new(
        Marten::Schema::DataHash{
          "username" => "TesT",
          "email"    => "jd@example.com",
        }
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should eq "username"
      schema.errors[0].message.should eq "This username is already taken"
    end

    it "returns false if the email address is already taken in a case insensitive way" do
      create_user(username: "test", email: "test@example.com", password: "insecure")

      schema = Profiles::SettingsUpdateSchema.new(
        Marten::Schema::DataHash{
          "username" => "jd",
          "email"    => "TesT@example.com",
        }
      )

      schema.valid?.should be_false

      schema.errors.size.should eq 1
      schema.errors[0].field.should eq "email"
      schema.errors[0].message.should eq "This email address is already taken"
    end
  end
end
