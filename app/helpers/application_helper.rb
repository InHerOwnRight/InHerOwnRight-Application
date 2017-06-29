module ApplicationHelper

  def collection_records
    @collection_records = Record.collections
  end

end
