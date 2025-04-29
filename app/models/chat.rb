# app/models/chat.rb
# == Schema Information
#
# Table name: chats
#
#  id               :uuid             not null, primary key
#  is_favorite      :boolean          default(FALSE)
#  last_activity_at :datetime
#  settings         :jsonb
#  status           :string           default("active")
#  thinking_enabled :boolean          default(FALSE)
#  title            :string
#  token            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  llm_provider_id  :uuid             not null
#  user_id          :uuid             not null
#
# Indexes
#
#  index_chats_on_llm_provider_id  (llm_provider_id)
#  index_chats_on_token            (token) UNIQUE
#  index_chats_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (llm_provider_id => llm_providers.id)
#  fk_rails_...  (user_id => users.id)
#
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
