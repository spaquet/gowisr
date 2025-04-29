# app/models/message.rb
# == Schema Information
#
# Table name: messages
#
#  id          :uuid             not null, primary key
#  content     :text
#  is_thinking :boolean          default(FALSE)
#  metadata    :jsonb
#  role        :string
#  status      :string           default("complete")
#  tokens_used :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  chat_id     :uuid             not null
#  user_id     :uuid
#
# Indexes
#
#  index_messages_on_chat_id  (chat_id)
#  index_messages_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_id => chats.id)
#  fk_rails_...  (user_id => users.id)
#
class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :user, optional: true
  has_many_attached :files

  validates :content, presence: true, unless: -> { files.attached? }
  validates :role, presence: true

  scope :chronological, -> { order(created_at: :asc) }
  scope :user_messages, -> { where(role: "user") }
  scope :assistant_messages, -> { where(role: "assistant") }
  scope :thinking_messages, -> { where(is_thinking: true) }

  after_create :update_chat_last_activity
  after_create :process_files, if: -> { files.attached? }

  def human?
    role == "user"
  end

  def assistant?
    role == "assistant"
  end

  def thinking?
    is_thinking?
  end

  def system?
    role == "system"
  end

  private

  def update_chat_last_activity
    chat.touch_activity
  end

  def process_files
    # Initialize metadata field if it doesn't exist
    self.metadata ||= {}
    self.metadata["files"] = []

    # Process each file
    files.each do |file|
      # Extract basic file info
      file_data = {
        name: file.filename.to_s,
        size: file.blob.byte_size,
        content_type: file.content_type,
        created_at: file.created_at
      }

      # Add to metadata
      self.metadata["files"] << file_data
    end

    # Save without callbacks to avoid infinite loop
    update_column(:metadata, self.metadata)
  end

  def files_within_limits
    return unless files.attached?

    llm = chat.llm_provider
    max_size = llm.max_file_size_mb.megabytes
    max_files = llm.max_files

    if files.count > max_files
      errors.add(:base, "Too many files. Maximum allowed is #{max_files}.")
    end

    files.each do |file|
      if file.blob.byte_size > max_size
        errors.add(:base, "File #{file.filename} is too large. Maximum size is #{max_size / 1.megabyte} MB.")
      end
    end
  end
end
