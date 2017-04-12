class DcRelation < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :relation
  end

end