class DcCreator < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :creator
  end

end