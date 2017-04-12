class DcSource < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :source
  end

end