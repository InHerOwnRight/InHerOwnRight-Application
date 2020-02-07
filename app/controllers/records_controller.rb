class RecordsController < ApplicationController


  def show
    @record = Record.friendly.find(params[:oai_identifier])

    if @record.is_collection?
      @collection_repository_url = @record.collection_repository_url
    end

  end

end
