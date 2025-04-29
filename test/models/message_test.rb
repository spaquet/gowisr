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
require "test_helper"

class MessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
