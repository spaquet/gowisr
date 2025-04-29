# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  # Use the application layout for public pages
  layout "application"

  def show
    # Render the requested static page
    render template: "pages/#{params[:page]}"
  rescue ActionView::MissingTemplate
    render file: "#{Rails.root}/public/404.html", status: :not_found
  end

  def pricing
  end

  def features
  end

  def about
  end

  def contact
  end

  def privacy
  end

  def terms
  end
end
