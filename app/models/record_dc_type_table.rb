class RecordDcTypeTable < ActiveRecord::Base
  belongs_to :record
  belongs_to :dc_type
end