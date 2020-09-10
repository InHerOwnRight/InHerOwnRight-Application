class CsvHarvestsController < ApplicationController
  include CsvHarvestHelper
  before_action :authorize_current_user

  def index
    @csv_harvests = CsvHarvest.order(created_at: :desc)
    @csv_harvest = CsvHarvest.new
  end

  def create
    if csv_harvest_params[:csv_file] && csv_harvest_params[:csv_file].content_type == 'text/csv'
      harvest = CsvHarvest.new(csv_harvest_params)
      if harvest.save
        CsvHarvestHelper.initiate(harvest)
        flash[:notice] = "New CSV harvest in progress.  Refresh page to update status below."
      else
        flash[:notice] = "CSV harvest failed to start."
      end
    elsif csv_harvest_params[:csv_file] && csv_harvest_params[:csv_file].content_type != 'text/csv'
      flash[:alert] = "CSV file required."
    else
      flash[:alert] = "No file detected."
    end
    redirect_to csv_harvests_path
  end

  private

  def csv_harvest_params
    params.fetch(:csv_harvest, {}).permit(:csv_file)
  end

  def authorize_current_user
    raise ActionController::RoutingError.new('Not Found') unless current_user
  end
end
