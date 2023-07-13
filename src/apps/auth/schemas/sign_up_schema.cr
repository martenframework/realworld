module Auth
  class SignUpSchema < Marten::Schema
    field :username, :string, max_size: 128
    field :email, :email
    field :password, :string, max_size: 128, strip: false

    validate :validate_username
    validate :validate_email

    private def validate_email
      return unless email?

      if User.filter(email__iexact: email).exists?
        errors.add(:email, "This email address is already taken")
      end
    end

    private def validate_username
      return unless username?

      if User.filter(profile__username__iexact: username).exists?
        errors.add(:username, "This username is already taken")
      end
    end
  end
end
