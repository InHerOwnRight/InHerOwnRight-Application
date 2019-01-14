class DcLanguage < ActiveRecord::Base
  belongs_to :record

  def readable_language
    Iso639[language]
  end
end