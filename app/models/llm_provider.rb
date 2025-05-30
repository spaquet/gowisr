# == Schema Information
#
# Table name: llm_providers
#
#  id                 :uuid             not null, primary key
#  active             :boolean          default(TRUE)
#  avatar_url         :string
#  default_parameters :jsonb
#  description        :text
#  llm_model_name     :string           not null
#  max_file_size_mb   :integer          default(10)
#  max_files          :integer          default(5)
#  name               :string           not null
#  provider_type      :string           not null
#  supports_files     :boolean          default(FALSE)
#  supports_thinking  :boolean          default(FALSE)
#  token_limit        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_llm_providers_on_provider_type_and_llm_model_name  (provider_type,llm_model_name) UNIQUE
#
class LlmProvider < ApplicationRecord
  scope :active, -> { where(active: true) }
end
