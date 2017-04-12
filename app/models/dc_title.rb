class DcTitle < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :title
  end

end