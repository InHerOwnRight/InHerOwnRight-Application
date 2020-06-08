class CoverageMapLocation < ActiveRecord::Base
  include MapLocation
  belongs_to :dc_coverage
  has_one :record, through: :dc_coverage
end
