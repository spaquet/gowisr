# app/helpers/authentication_helper.rb

module AuthenticationHelper
  # Devise-like helper methods for Stytch authentication

  # Check if a user is currently logged in
  def user_signed_in?
    current_user.present?
  end

  # Get the current user from the session
  def current_user
    return @current_user if defined?(@current_user)

    Rails.logger.debug "Fetching current_user: session[:user_id]=#{session[:user_id]}"
    @current_user = nil
    if session[:user_id].present?
      @current_user = User.find_by(id: session[:user_id])
    end

    @current_user
  end

  # Authenticate user and redirect to login page if not authenticated
  def authenticate_user!
    unless user_signed_in?
      redirect_to auth_login_path, alert: "You need to sign in or sign up before continuing."
    end
  end

  # Handle Stytch authentication callback
  def authenticate_with_stytch(token)
    stytch_client = Stytch::Client.new(
      project_id: ENV["STYTCH_PROJECT_ID"],
      secret: ENV["STYTCH_SECRET_KEY"],
      env: Rails.env.production? ? :live : :test
    )

    begin
      response = stytch_client.magic_links.authenticate(token: token, session_duration_minutes: 60)
      Rails.logger.debug("Authenticate response: #{response.inspect}")

      # Handle already used or expired magic link
      if response["status_code"] == 401 && response["error_type"] == "unable_to_auth_magic_link"
        Rails.logger.info("Magic link already used or expired: #{response['error_message']}")
        return { error: :magic_link_expired, message: "The magic link has expired or has already been used. Please request a new one." }
      end

      unless response["status_code"] == 200
        Rails.logger.error("Stytch authentication failed with status: #{response['status_code']}, error: #{response['error_message']}")
        return { error: :authentication_failed, message: "Authentication failed. Please try again." }
      end

      unless response["user_id"] && response["session_token"]
        Rails.logger.error("Missing user_id or session_token in response")
        return { error: :missing_data, message: "Missing required data from Stytch. Please contact support." }
      end

      user = User.find_or_initialize_by(stytch_user_id: response["user_id"])
      if user.new_record? && response["user"] && response["user"]["emails"]&.first
        user.email = response["user"]["emails"].first["email"]
        user.save!
      end

      session[:user_id] = user.id
      session[:stytch_session_token] = response["session_token"]
      user
    rescue StandardError => e
      Rails.logger.error("Stytch authentication error: #{e.message}")
      { error: :unexpected_error, message: "An unexpected error occurred. Please try again." }
    end
  end

  # Sign out the current user
  def sign_out
    session.delete(:user_id)
    session.delete(:stytch_session_token)
    @current_user = nil
  end

  # Check if the user is verified (e.g., email verification)
  def user_verified?
    user_signed_in? && current_user.verified?
  end
end
