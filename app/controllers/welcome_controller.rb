# app/controllers/welcome_controller.rb
class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  # Use the application layout for the welcome page
  layout "application"

  def index
  end
end
