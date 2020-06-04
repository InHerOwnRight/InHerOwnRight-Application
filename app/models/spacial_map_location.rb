class SpacialMapLocation < ActiveRecord::Base
  include MapLocation
  belongs_to :dc_terms_spacial
  has_one :record, through: :dc_terms_spacial
end
