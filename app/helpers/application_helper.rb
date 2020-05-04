module ApplicationHelper
  include SpotlightHelper

  def collection_records
    @collection_records = Record.collections
  end

end
