class RecordsController < ApplicationController

  def show
    @record = Record.friendly.find(params[:oai_identifier])

    @document = {}
    @document['geojson_ssim'] = @record.map_locations.pluck(:geojson_ssim)

    if @record.is_collection?
      @collection_repository_url = @record.collection_repository_url
    end

    render layout: 'blacklight-maps/blacklight-maps'
  end

end
