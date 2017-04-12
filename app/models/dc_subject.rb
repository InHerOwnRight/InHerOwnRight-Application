class DcSubject < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :subject
  end

end