class DcTitle < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :title
    integer :record_id
  end

end