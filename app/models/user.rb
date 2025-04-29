# app/models/user.rb
class User < ApplicationRecord
  # Associations
  has_many :chats, dependent: :destroy
  has_many :messages, dependent: :nullify
  has_many :llm_interactions, through: :chats

  # Validations
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :stytch_user_id, presence: true, uniqueness: true
  validates :username, uniqueness: true, allow_nil: true,
            format: { with: /\A[a-zA-Z0-9_.-]+\z/, message: "can only contain letters, numbers, and _ . -" },
            length: { minimum: 3, maximum: 30 }, if: -> { username.present? }

  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  # Callbacks
  before_validation :generate_username, on: :create, if: -> { username.blank? }

  # Methods
  def verify!
    update(verified: true)
  end

  def display_name
    name.presence || username.presence || email.split("@").first.titleize
  end

  def avatar_url(size: 80)
    return self[:avatar_url] if self[:avatar_url].present?

    if use_gravatar?
      email_md5 = Digest::MD5.hexdigest(email.downcase)
      "https://www.gravatar.com/avatar/#{email_md5}?s=#{size}&d=mp"
    else
      # Using DiceBear for abstract, non-human avatars
      "https://api.dicebear.com/7.x/shapes/svg?seed=#{ERB::Util.url_encode(email)}&size=#{size}&backgroundColor=2563eb"
    end
  end

  def has_gravatar?
    return true if self[:avatar_url].present?
    return false unless use_gravatar?

    email_md5 = Digest::MD5.hexdigest(email.downcase)
    gravatar_url = "https://www.gravatar.com/avatar/#{email_md5}?s=80&d=404"

    begin
      uri = URI(gravatar_url)
      request = Net::HTTP.new(uri.host, uri.port)
      request.use_ssl = true
      response = request.request_head(uri.path + "?" + uri.query.to_s)
      response.code.to_i == 200
    rescue
      false
    end
  end

  def update_gravatar_status
    update(use_gravatar: has_gravatar?)
  end

  def from_oauth?
    provider.present? && uid.present?
  end

  def favorite_chats
    chats.where(is_favorite: true).order(last_activity_at: :desc)
  end

  def recent_chats(limit = 10)
    chats.active.order(last_activity_at: :desc).limit(limit)
  end

  def create_chat(params)
    chats.create(params)
  end

  private

  def generate_username
    base_username = email.split("@").first.downcase.gsub(/[^a-z0-9]/, "")
    self.username = find_unique_username(base_username)
  end

  def find_unique_username(base)
    # Try the base username first
    return base unless User.exists?(username: base)

    # If that's taken, add a number until we find an available one
    num = 1
    while User.exists?(username: "#{base}#{num}")
      num += 1
    end

    "#{base}#{num}"
  end
end
