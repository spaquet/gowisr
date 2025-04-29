# app/models/user.rb

class User < ApplicationRecord
  # Validations
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :stytch_user_id, presence: true, uniqueness: true

  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  # Methods
  def verify!
    update(verified: true)
  end

  def display_name
    email.split("@").first.titleize
  end
end
