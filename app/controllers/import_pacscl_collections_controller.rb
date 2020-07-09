class ImportPacsclCollectionsController < ApplicationController
  include ImportPacsclCollectionsHelper
  before_action :authorize_current_user

  def index
    @pacscl_collections = PacsclCollection.includes(:repository).all
  end

  def create
    if params[:file] && params[:file].content_type == 'text/csv'
      ImportPacsclCollectionsHelper.save_file(params[:file])
      ImportPacsclCollectionsHelper.initiate
      flash[:notice] = "PACSCL collections imported successfully"
    elsif params[:file]
      flash[:alert] = "File required to be CSV"
    else
      flash[:alert] = "No file detected"
    end
    redirect_to import_pacscl_collections_path
  end

  private

  def authorize_current_user
    raise ActionController::RoutingError.new('Not Found') unless current_user
  end
end
