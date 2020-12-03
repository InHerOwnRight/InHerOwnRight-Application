class PacsclOaiController < ApplicationController
  def index
    # Remove controller and action from the options. Rails adds them automatically.
    options = params.delete_if { |k,v| %w{controller action}.include?(k) }
    provider = PacsclOaiProvider.new
    response = provider.process_request(options)
    render plain: response, content_type: "text/xml", layout: false
  end
end