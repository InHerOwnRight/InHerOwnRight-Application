class PacsclOaiController < ApplicationController
  def index
    provider = PacsclOaiProvider.new
    response = provider.process_request(oai_params.to_h)
    render plain: response, content_type: "text/xml", layout: false
  end

  private

  def oai_params
    params.permit(:verb, :identifier, :metadataPrefix, :set, :from, :until, :resumptionToken)
  end
end