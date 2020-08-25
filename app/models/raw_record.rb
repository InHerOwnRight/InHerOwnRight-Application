class RawRecord < ActiveRecord::Base
  belongs_to :repository
  belongs_to :harvest
  has_one :record
end
