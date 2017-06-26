class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout 'blacklight'

  def titleize_dropdown_links(title)
    title.gsub('_', ' ').titleize
  end
  helper_method :titleize_dropdown_links

  protect_from_forgery with: :exception
end
