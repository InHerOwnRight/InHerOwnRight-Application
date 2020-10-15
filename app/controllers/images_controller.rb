class ImagesController < ApplicationController
  include Blacklight::Catalog

  def manifest
    # @response, @document = search_service.fetch(params[:id])

    @document = Record.find_by_slug(params[:id])
    render json: @document.to_json
  end

  protected
  def search_service
    search_service_class.new(config: blacklight_config, user_params: search_state.to_h, **search_service_context)
  end
end
