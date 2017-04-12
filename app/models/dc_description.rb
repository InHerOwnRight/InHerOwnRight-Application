class DcDescription < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :description
  end

end