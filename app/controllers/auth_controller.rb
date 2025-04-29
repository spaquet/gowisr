# app/controllers/auth_controller.rb

class AuthController < ApplicationController
  include AuthenticationHelper

  # Skip authentication checks for these actions
  skip_before_action :authenticate_user!, only: [ :login, :register, :callback, :magic_link ]

  # Display login form
  def login
    # Redirect to dashboard if already logged in
    redirect_to dashboard_path if user_signed_in?
  end

  # Display registration form
  def register
    # Redirect to dashboard if already logged in
    redirect_to dashboard_path if user_signed_in?
  end

  # Send login or registration magic link
  def magic_link
    Rails.logger.debug "Entering magic_link action with email: #{params[:email]}"

    email = params[:email].to_s.strip.downcase

    if email.blank? || !email.match?(/\A[^@\s]+@[^@\s]+\z/)
      Rails.logger.debug "Invalid email, rendering login"
      flash.now[:alert] = "Please enter a valid email address."
      respond_to do |format|
        # format.html { render :login }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash") }
      end
      return
    end

    # Configure Stytch client
    stytch_client = Stytch::Client.new(
      project_id: ENV["STYTCH_PROJECT_ID"],
      secret: ENV["STYTCH_SECRET_KEY"],
      env: Rails.env.production? ? :live : :test
    )

    # Set up magic link parameters
    magic_link_params = {
      email: email,
      login_magic_link_url: auth_callback_url,
      signup_magic_link_url: auth_callback_url
    }

    # Log the callback URL
    Rails.logger.debug "auth_callback_url: #{auth_callback_url}"

    # Send magic link using login_or_create
    begin
      response = stytch_client.magic_links.email.login_or_create(**magic_link_params)
      Rails.logger.debug "Magic link sent successfully: #{response.inspect}"

      # Check if a new user was created
      if response["user_id"]
        Rails.logger.debug "User processed with user_id: #{response['user_id']}"
      end

      # Set success message based on environment
      success_message = Rails.env.production? ?
        "A magic link has been sent to #{email}. Please check your inbox and spam folder." :
        "A magic link has been sent! Check the Stytch Dashboard for the test link."

      respond_to do |format|
        # format.html { redirect_to auth_link_sent_path(email: email), notice: success_message }
        format.turbo_stream do
          flash.now[:notice] = success_message
          render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash")
        end
      end
    rescue StandardError => e
      Rails.logger.error "Error sending magic link: #{e.message}"
      flash.now[:alert] = "We couldn’t send the magic link. Please try again or contact support."
      respond_to do |format|
        # format.html { render :login }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash") }
      end
    end
  end

  # Show page after magic link is sent
  def link_sent
    @email = params[:email]
  end

  # Handle magic link callback
  def callback
    token = params[:token]

    if token.blank?
      redirect_to auth_login_path, alert: "Invalid or missing token"
      return
    end

    result = authenticate_with_stytch(token)

    if result.is_a?(Hash) && result[:error]
      case result[:error]
      when :magic_link_expired
        flash[:alert] = result[:message]
      when :authentication_failed
        flash[:alert] = result[:message]
      when :missing_data
        flash[:alert] = result[:message]
      when :unexpected_error
        flash[:alert] = result[:message]
      end
      redirect_to auth_login_path
    elsif result
      redirect_to dashboard_path, notice: "Successfully signed in"
    else
      redirect_to auth_login_path, alert: "Authentication failed. Please try again."
    end
  end

  # Log out the user
  def logout
    sign_out
    redirect_to root_path, notice: "Successfully signed out"
  end
end
