class DcLanguage < ActiveRecord::Base
  belongs_to :record

  searchable do
    text :language
  end

end