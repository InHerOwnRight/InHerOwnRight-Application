class DcFormat < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :format
  end

end