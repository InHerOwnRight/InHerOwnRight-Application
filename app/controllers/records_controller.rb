class RecordsController < ApplicationController


  def show
    @record = Record.friendly.find(params[:oai_identifier])

    if @record.is_collection?
      @collection_repository_url = @record.collection_repository_url
    end

  end

  def display_date_range(record)
    "#{record.dc_dates.minimum(:date).strftime("%Y-%m-%d")} &ndash; #{record.dc_dates.maximum(:date).strftime("%Y-%m-%d")}".html_safe
  end
  helper_method :display_date_range

end
