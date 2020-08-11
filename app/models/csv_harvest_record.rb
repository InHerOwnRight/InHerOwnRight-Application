class CsvHarvestRecord < ActiveRecord::Base
  belongs_to :record
  belongs_to :csv_harvest
end
