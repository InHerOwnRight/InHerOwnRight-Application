class DcPublisher < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :publisher
  end

end