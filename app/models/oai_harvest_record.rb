class OaiHarvestRecord < ActiveRecord::Base
  belongs_to :record
  belongs_to :oai_harvest
end
