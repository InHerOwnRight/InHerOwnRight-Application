class WebsiteSearchController < ApplicationController
  def index
    @production_env = true if Rails.env.production?
  end
end
