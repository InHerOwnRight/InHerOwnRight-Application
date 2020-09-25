class DcTermsSpacial < ActiveRecord::Base
  belongs_to :record
  has_many :spacial_map_locations, dependent: :destroy
  after_save :update_map_locations, if: :saved_change_to_spacial?
  around_destroy :reindex_record_after_destroy

  def update_map_locations
    changed = false
    spacial_map_locations.update_all(verified: nil)
    delimiters = [';', '|']
    placenames = spacial.split(Regexp.union(delimiters)).map(&:strip)
    placenames.each do |placename|
      spacial_map_location = spacial_map_locations.find_by(placename: placename)
      if spacial_map_location
        spacial_map_location.update_attributes(verified: DateTime.now)
      else
        changed = true
        spacial_map_location = spacial_map_locations.create(placename: placename)
      end
      spacial_map_location.geocode_from_placename_to_location if spacial_map_location.geocode_attempt.nil?
    end
    if spacial_map_locations.not_verified.any?
      changed = true
      spacial_map_locations.not_verified.destroy_all
    end
    reindex_record if changed
  end

  def force_update_map_locations
    changed = false
    spacial_map_locations.update_all(verified: nil)
    delimiters = [';', '|']
    placenames = spacial.split(Regexp.union(delimiters)).map(&:strip)
    placenames.each do |placename|
      spacial_map_location = spacial_map_locations.find_by(placename: placename)
      if spacial_map_location
        spacial_map_location.update_attributes(verified: DateTime.now)
      else
        changed = true
        spacial_map_location = spacial_map_locations.create(placename: placename)
      end
      spacial_map_location.geocode_from_placename_to_location
    end
    if spacial_map_locations.not_verified.any?
      changed = true
      spacial_map_locations.not_verified.destroy_all
    end
    reindex_record
  end

  private

  def reindex_record
    Sunspot.index!(record)
  end

  def reindex_record_after_destroy
    parent_record = record
    yield
    Sunspot.index!(parent_record)
  end
end
