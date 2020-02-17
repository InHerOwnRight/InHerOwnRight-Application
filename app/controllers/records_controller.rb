class RecordsController < ApplicationController


  def show
    @record = Record.friendly.find(params[:oai_identifier])

    if @record.is_collection?
      @collection_repository_url = @record.collection_repository_url
    end

  end

  def joined_dates(dc_dates)
    dc_dates.map do |dc_date|
      if dc_date.date
        dc_date.date.strftime("%Y-%m-%d")
      elsif dc_date.english_date
        dc_date.english_date
      else
        dc_date.unprocessed_date
      end
    end.join(" | ")
  end
  helper_method :joined_dates

end
