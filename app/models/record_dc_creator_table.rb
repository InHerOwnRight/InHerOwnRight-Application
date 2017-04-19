class RecordDcCreatorTable < ActiveRecord::Base
  belongs_to :record
  belongs_to :dc_creator
end