class DcDate < ActiveRecord::Base
  belongs_to :record

  scope :original_creation_date, -> { where("date < ?", Date.new(1950) )}
end