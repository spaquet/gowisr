# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat
  before_action :set_message, only: [ :show, :destroy ]

  def create
    @message = @chat.messages.new(message_params)
    @message.user = current_user
    @message.role = "user"

    # Attach files if present
    if params[:message][:files].present?
      params[:message][:files].each do |file|
        @message.files.attach(file)
      end
    end

    respond_to do |format|
      if @message.save
        # Process the message with LLM
        LlmProcessorJob.perform_later(@chat.id, @message.id)

        format.html { redirect_to chat_path(@chat) }
        format.turbo_stream
      else
        format.html { redirect_to chat_path(@chat), alert: "Failed to send message." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message_form", partial: "form", locals: { chat: @chat, message: @message }) }
      end
    end
  end

  def destroy
    @message.destroy

    respond_to do |format|
      format.html { redirect_to chat_path(@chat) }
      format.turbo_stream
    end
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  def set_message
    @message = @chat.messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content, files: [])
  end
end
