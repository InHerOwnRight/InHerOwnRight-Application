class DcCoverage < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :coverage
  end

end