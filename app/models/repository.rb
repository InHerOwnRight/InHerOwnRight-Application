class Repository < ActiveRecord::Base
  has_many :raw_records
  has_many :records, through: :raw_records
  has_many :pacscl_collections
end
