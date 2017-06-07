class DcIdentifier < ActiveRecord::Base
  belongs_to :record

  def identifier_is_url?
    identifier.split(":").first == "http" || identifier.split(":").first == "https"
  end

end