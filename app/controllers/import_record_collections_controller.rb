class ImportRecordCollectionsController < ApplicationController
  include ImportRecordCollectionsHelper
  before_action :authorize_current_user

  def index
    @record_collections = RawRecord.where(record_type: "collection").map { |rr| rr.record }
  end

  def create
    if params[:file] && params[:file].content_type == 'text/csv'
      ImportRecordCollectionsHelper.save_file(params[:file])
      ImportRecordCollectionsHelper.initiate
      flash[:notice] = "Record collections imported successfully"
    elsif params[:file]
      flash[:alert] = "File required to be CSV"
    else
      flash[:alert] = "No file detected"
    end
    redirect_to import_record_collections_path
  end

  private

  def authorize_current_user
    raise ActionController::RoutingError.new('Not Found') unless current_user
  end
end
