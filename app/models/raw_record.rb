class RawRecord < ActiveRecord::Base
  belongs_to :repository
  has_one :record
end