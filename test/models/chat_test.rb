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
require "test_helper"

class ChatTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
