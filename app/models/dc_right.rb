class DcRight < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :rights
  end

end