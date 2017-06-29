class RecordDcSubjectTable < ActiveRecord::Base
  belongs_to :record
  belongs_to :dc_subject
end