# app/jobs/llm_processor_job.rb
class LlmProcessorJob < ApplicationJob
  queue_as :default

  def perform(chat_id, message_id)
    chat = Chat.find(chat_id)
    message = Message.find(message_id)
    llm_provider = chat.llm_provider

    # Create a "thinking" message if enabled
    if chat.thinking_enabled && llm_provider.supports_thinking
      thinking_message = chat.add_thinking_message("Thinking...")
      broadcast_thinking(chat, thinking_message)
    end

    # Configure LLM client
    client = LlmClient.new(llm_provider.client_config)

    # Prepare conversation history for context
    history = chat.messages.where(is_thinking: false).map do |msg|
      {
        role: msg.role,
        content: msg.content
      }
    end

    # Process attachments if any
    attachments_content = process_attachments(message)

    # Generate response from LLM
    response = client.generate_response(history, attachments_content)

    # Save assistant's response
    assistant_message = chat.add_assistant_message(
      response[:content],
      { tokens_used: response[:tokens_used] }
    )

    # Remove thinking message if it exists
    if chat.thinking_enabled && llm_provider.supports_thinking
      chat.thinking_messages.destroy_all
    end

    # Broadcast the assistant's response
    broadcast_response(chat, assistant_message)
  end

  private

  def process_attachments(message)
    return nil unless message.files.attached?

    # Extract basic information about files
    files_info = message.files.map do |file|
      "- #{file.filename} (#{number_to_human_size(file.blob.byte_size)}, #{file.content_type})"
    end.join("\n")

    # For text-based files, extract content
    text_content = message.files.map do |file|
      next unless file.content_type.start_with?("text/") ||
                  [ "application/json", "application/xml", "application/csv" ].include?(file.content_type)

      begin
        content = file.download
        "File: #{file.filename}\nContent:\n#{content[0..5000]}#{content.size > 5000 ? '...(truncated)' : ''}"
      rescue => e
        Rails.logger.error("Failed to process file #{file.filename}: #{e.message}")
        nil
      end
    end.compact.join("\n\n")

    result = "Attached files:\n#{files_info}"
    result += "\n\n#{text_content}" if text_content.present?
    result
  end

  def broadcast_thinking(chat, message)
    Turbo::StreamsChannel.broadcast_append_to(
      "chat_#{chat.id}_messages",
      target: "chat_messages",
      partial: "messages/thinking_message",
      locals: { message: message }
    )
  end

  def broadcast_response(chat, message)
    Turbo::StreamsChannel.broadcast_append_to(
      "chat_#{chat.id}_messages",
      target: "chat_messages",
      partial: "messages/message",
      locals: { message: message }
    )
  end

  def number_to_human_size(size)
    ActiveSupport::NumberHelper.number_to_human_size(size)
  end
end
