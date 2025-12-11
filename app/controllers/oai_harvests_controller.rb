class OaiHarvestsController < ApplicationController
  include OaiHarvestHelper
  before_action :authorize_current_user

  def index
    @all_oai_harvests = OAIHarvest.all.order(created_at: :desc)
    @oai_harvests = @all_oai_harvests.filter { |harvest| harvest.records.count != 1 } || []
    @single_record_oai_harvests = @all_oai_harvests.filter { |harvest| harvest.records.count == 1 } || []
    @oai_harvest = OAIHarvest.new
    @repositories = Repository.where.not(oai_task: nil)
  end

  def create
    oai_record_id = oai_record_id_from_params
    if oai_harvest_params[:repository_id] == "TriColleges"
      tricollege_repos = Repository.where(short_name: ["Swarthmore - Friends", "Swarthmore - Peace"])
      tricollege_repo_ids = tricollege_repos.all.map(&:id)
      if !OAIHarvest.where(repository_id: tricollege_repo_ids).where.not(status: "complete").empty?
        flash[:notice] = "A harvest is already in progress for TriColleges."
      else
        harvest = OAIHarvest.create(oai_harvest_params)
        OaiHarvestHelper.initiate(harvest, oai_record_id)
        flash[:notice] = "New OAI harvest in progress.  Refresh page to update status below."
      end
    else
      if !OAIHarvest.where(repository_id: oai_harvest_params[:repository_id]).where.not(status: "complete").empty?
        repo = Repository.find(oai_harvest_params[:repository_id])
        flash[:notice] = "A harvest is already in progress for #{repo.short_name}."
      else
        harvest = OAIHarvest.create(oai_harvest_params)
        OaiHarvestHelper.initiate(harvest, oai_record_id)
        flash[:notice] = "New OAI harvest in progress.  Refresh page to update status below."
      end
    end
    redirect_to oai_harvests_path
  end

  private

  def oai_harvest_params
    params.require(:oai_harvest).permit(:repository_id)
    #params.permit(:oai_harvest, :repository_id)
  end

  def oai_record_id_from_params
    params[:oai_record_id]&.strip
  end

  def authorize_current_user
    raise ActionController::RoutingError.new('Not Found') unless current_user
  end
end
