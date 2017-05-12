class RecordsController < ApplicationController

  def show
    @record = Record.find(params[:id])
  end

  def display_date_range(record)
    "#{record.dc_dates.minimum(:date).year} &ndash; #{record.dc_dates.maximum(:date).year}".html_safe
  end
  helper_method :display_date_range

end