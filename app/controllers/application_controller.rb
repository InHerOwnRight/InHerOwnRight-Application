class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller

  layout :determine_layout if respond_to? :layout

  def titleize_dropdown_links(title)
    title.gsub('_', ' ').titleize
  end
  helper_method :titleize_dropdown_links

  protect_from_forgery with: :exception

  before_action :set_raven_context

  # before_action :alter_facet_config

  def set_raven_context
    # Include current_user_id and params with exceptions sent to Sentry
    Raven.user_context(user_id: session[:current_user_id])
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def current_exhibit
    @exhibit || (Spotlight::Exhibit.find(params[:exhibit_id])) if params[:exhibit_id].present?
  end

  def alter_facet_config
    if request.path.include?("spotlight")
      filename = Rails.root.join('app', 'controllers', 'catalog_controller.rb')
      content = File.read(filename)
      if !content.include?("# config.add_facet_fields_to_solr_request!")
        outdata = File.read(filename).gsub("config.add_facet_fields_to_solr_request!", "# config.add_facet_fields_to_solr_request!")
        File.open(filename, 'w') do |out|
          out << outdata
        end
      end
    else
      filename = Rails.root.join('app', 'controllers', 'catalog_controller.rb')
      content = File.read(filename)
      outdata = File.read(filename).gsub("# config.add_facet_fields_to_solr_request!", "config.add_facet_fields_to_solr_request!")
      File.open(filename, 'w') do |out|
        out << outdata
      end
    end
  end

end
