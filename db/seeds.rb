# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

llm_providers = [
  {
    name: "Claude 3 Opus",
    provider_type: "anthropic",
    model_name: "claude-3-opus-20240229",
    description: "Most powerful model for highly complex tasks requiring deep expertise and outstanding performance.",
    supports_thinking: true,
    supports_files: true,
    token_limit: 200000,
    max_file_size_mb: 100,
    max_files: 10,
    avatar_url: "https://assets.website-files.com/62a95af312ef3fe21a6c65c9/65f0eaf09e244b7d21ff1a7f_anthropic-symbol-gradient.svg",
    default_parameters: {
      temperature: 0.7,
      max_tokens: 4000
    }
  },
  {
    name: "Claude 3 Sonnet",
    provider_type: "anthropic",
    model_name: "claude-3-sonnet-20240229",
    description: "Ideal balance of intelligence and speed for enterprise workloads.",
    supports_thinking: true,
    supports_files: true,
    token_limit: 200000,
    max_file_size_mb: 100,
    max_files: 10,
    avatar_url: "https://assets.website-files.com/62a95af312ef3fe21a6c65c9/65f0eaf09e244b7d21ff1a7f_anthropic-symbol-gradient.svg",
    default_parameters: {
      temperature: 0.7,
      max_tokens: 4000
    }
  },
  {
    name: "Claude 3 Haiku",
    provider_type: "anthropic",
    model_name: "claude-3-haiku-20240307",
    description: "Fastest and most compact model for near-instant responsiveness.",
    supports_thinking: false,
    supports_files: true,
    token_limit: 200000,
    max_file_size_mb: 100,
    max_files: 10,
    avatar_url: "https://assets.website-files.com/62a95af312ef3fe21a6c65c9/65f0eaf09e244b7d21ff1a7f_anthropic-symbol-gradient.svg",
    default_parameters: {
      temperature: 0.7,
      max_tokens: 4000
    }
  },
  {
    name: "GPT-4o",
    provider_type: "openai",
    model_name: "gpt-4o",
    description: "Most capable model, optimized for speed and multimodal capabilities.",
    supports_thinking: false,
    supports_files: true,
    token_limit: 128000,
    max_file_size_mb: 50,
    max_files: 10,
    avatar_url: "https://seeklogo.com/images/O/open-ai-logo-8B9BFEDC26-seeklogo.com.png",
    default_parameters: {
      temperature: 0.7,
      max_tokens: 4000
    }
  },
  {
    name: "GPT-4 Turbo",
    provider_type: "openai",
    model_name: "gpt-4-turbo-preview",
    description: "Fast and powerful model with knowledge up to April 2023.",
    supports_thinking: false,
    supports_files: true,
    token_limit: 128000,
    max_file_size_mb: 50,
    max_files: 10,
    avatar_url: "https://seeklogo.com/images/O/open-ai-logo-8B9BFEDC26-seeklogo.com.png",
    default_parameters: {
      temperature: 0.7,
      max_tokens: 4000
    }
  },
  {
    name: "GPT-3.5 Turbo",
    provider_type: "openai",
    model_name: "gpt-3.5-turbo",
    description: "Smart, fast, and economical model for a wide range of tasks.",
    supports_thinking: false,
    supports_files: false,
    token_limit: 16000,
    max_file_size_mb: 20,
    max_files: 5,
    avatar_url: "https://seeklogo.com/images/O/open-ai-logo-8B9BFEDC26-seeklogo.com.png",
    default_parameters: {
      temperature: 0.7,
      max_tokens: 4000
    }
  },
  {
    name: "Gemini Pro",
    provider_type: "google",
    model_name: "gemini-pro",
    description: "Google's capable large language model for various tasks.",
    supports_thinking: false,
    supports_files: false,
    token_limit: 30000,
    max_file_size_mb: 10,
    max_files: 5,
    avatar_url: "https://lh3.googleusercontent.com/vvBAqyr3kNaF8TVwgNbFraGnnzEkbYGqMxVwE_cYAuMlvkQu-T92mwbQM-cEQF_FxEJHYrjR7SXsYCy5dFfvJlVtPfHSaSAH-4HtaV1w7A",
    default_parameters: {
      temperature: 0.7,
      max_tokens: 2048
    }
  }
]

llm_providers.each do |provider_data|
  LlmProvider.find_or_create_by!(
    provider_type: provider_data[:provider_type],
    model_name: provider_data[:model_name]
  ) do |provider|
    provider.assign_attributes(provider_data)
  end
end

puts "Seeded #{LlmProvider.count} LLM providers"
