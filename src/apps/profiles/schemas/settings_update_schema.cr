module Profiles
  class SettingsUpdateSchema < Marten::Schema
    property current_profile : Profile? = nil

    field :username, :string, max_size: 128
    field :email, :email
    field :password, :string, max_size: 128, strip: false, required: false
    field :image_url, :url, required: false
    field :bio, :string, max_size: 10_000, required: false

    validate :validate_email
    validate :validate_username

    private def validate_email
      return unless email?

      if Profile.filter(user__email__iexact: email).exclude(pk: current_profile.try(&.pk)).exists?
        errors.add(:email, "This email address is already taken")
      end
    end

    private def validate_username
      return unless username?

      if Profile.filter(username__iexact: username).exclude(pk: current_profile.try(&.pk)).exists?
        errors.add(:username, "This username is already taken")
      end
    end
  end
end
