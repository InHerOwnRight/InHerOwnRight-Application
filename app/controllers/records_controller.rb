class RecordsController < ApplicationController


  def show
    @record = Record.find(params[:id])

    if @record.is_collection?
      @collection_repository_url = @record.collection_repository_url
    end

  end

  def display_date_range(record)
    "#{record.dc_dates.minimum(:date).year} &ndash; #{record.dc_dates.maximum(:date).year}".html_safe
  end
  helper_method :display_date_range

end