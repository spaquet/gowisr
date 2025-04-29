# app/models/chat.rb
class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :llm_provider
  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy

  validates :title, presence: true, unless: :new_record?

  before_create :set_default_title
  before_create :generate_token

  scope :active, -> { where(status: "active") }
  scope :favorites, -> { where(is_favorite: true) }
  scope :recent, -> { order(last_activity_at: :desc) }

  def user_messages
    messages.where(role: "user")
  end

  def assistant_messages
    messages.where(role: "assistant")
  end

  def thinking_messages
    messages.where(is_thinking: true)
  end

  def add_user_message(content)
    messages.create!(
      role: "user",
      content: content,
      user: self.user
    )
  end

  def add_assistant_message(content, metadata = {})
    messages.create!(
      role: "assistant",
      content: content,
      metadata: metadata
    )
  end

  def add_thinking_message(content)
    return unless thinking_enabled?

    messages.create!(
      role: "assistant",
      content: content,
      is_thinking: true
    )
  end

  def last_message
    messages.order(created_at: :asc).last
  end

  def touch_activity
    update_column(:last_activity_at, Time.current)
  end

  private

  def set_default_title
    self.title ||= "New Chat"
    self.last_activity_at ||= Time.current
  end

  def generate_token
    self.token = SecureRandom.hex(10)
  end
end
