class DcContributor < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :contributor
  end

end