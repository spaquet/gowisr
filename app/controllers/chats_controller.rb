# app/controllers/chats_controller.rb
class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [ :show, :update, :destroy, :toggle_favorite, :toggle_thinking ]

  def index
    @chats = current_user.chats.active.recent
    @favorites = current_user.chats.favorites.recent
    @llm_providers = LlmProvider.active
  end

  def show
    @messages = @chat.messages.includes(:attachments).chronological
    @llm_providers = LlmProvider.active
  end

  def new
    @llm_providers = LlmProvider.active
    @chat = Chat.new
  end

  def create
    @chat = current_user.chats.new(chat_params)

    respond_to do |format|
      if @chat.save
        format.html { redirect_to chat_path(@chat), notice: "Chat started successfully." }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_chat_form", partial: "form", locals: { chat: @chat }) }
      end
    end
  end

  def update
    respond_to do |format|
      if @chat.update(chat_params)
        format.html { redirect_to chat_path(@chat), notice: "Chat updated successfully." }
        format.turbo_stream
      else
        format.html { render :show, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("chat_header", partial: "header", locals: { chat: @chat }) }
      end
    end
  end

  def destroy
    @chat.update(status: "deleted")

    respond_to do |format|
      format.html { redirect_to chats_path, notice: "Chat deleted successfully." }
      format.turbo_stream
    end
  end

  def toggle_favorite
    @chat.update(is_favorite: !@chat.is_favorite)

    respond_to do |format|
      format.html { redirect_to chat_path(@chat) }
      format.turbo_stream
    end
  end

  def toggle_thinking
    @chat.update(thinking_enabled: !@chat.thinking_enabled)

    respond_to do |format|
      format.html { redirect_to chat_path(@chat) }
      format.turbo_stream
    end
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:title, :llm_provider_id, :thinking_enabled)
  end
end
