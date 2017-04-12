class DcIdentifier < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :identifier
  end

end