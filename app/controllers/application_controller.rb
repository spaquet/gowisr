# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include AuthenticationHelper

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  # Set the default layout based on authentication status
  layout :determine_layout

  # Make these helpers available to views
  helper_method :current_user, :user_signed_in?, :user_verified?

  protected

  # Determine which layout to use based on authentication status
  def determine_layout
    user_signed_in? ? "authenticated" : "application"
  end

  # Override default behavior for authentication failures
  def authenticate_user!
    Rails.logger.debug "Checking authentication: user_signed_in?=#{user_signed_in?}, session[:user_id]=#{session[:user_id]}"
    unless user_signed_in?
      session[:return_to] = request.fullpath if request.get?
      redirect_to auth_login_path, alert: "You need to sign in or sign up before continuing."
    end
  end

  # Redirect to the stored path after authentication or to a default path
  def redirect_back_or_default(default_path)
    path = session.delete(:return_to) || default_path
    redirect_to path
  end
end
