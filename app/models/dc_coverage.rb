class DcCoverage < ActiveRecord::Base
  belongs_to :record
  has_many :coverage_map_locations, dependent: :destroy
  after_save :update_map_locations, if: :saved_change_to_coverage?
  around_destroy :reindex_record_after_destroy

  def update_map_locations
    changed = false
    coverage_map_locations.update_all(verified: nil)
    placenames.each do |placename|
      coverage_map_location = coverage_map_locations.find_by(placename: placename)
      if coverage_map_location
        coverage_map_location.update_attributes(verified: DateTime.now)
      else
        changed = true
        coverage_map_location = coverage_map_locations.create(placename: placename)
      end
      coverage_map_location.geocode_from_placename_to_location if coverage_map_location.geocode_attempt.nil?
    end
    if coverage_map_locations.not_verified.any?
      changed = true
      coverage_map_locations.not_verified.destroy_all
    end
    reindex_record if changed
  end

  def placenames
    delimiters = [';', '|']
    coverage.split(Regexp.union(delimiters)).map(&:strip)
  end

  def force_update_map_locations
    changed = false
    coverage_map_locations.update_all(verified: nil)
    placenames.each do |placename|
      coverage_map_location = coverage_map_locations.find_by(placename: placename)
      if coverage_map_location
        coverage_map_location.update_attributes(verified: DateTime.now)
      else
        changed = true
        coverage_map_location = coverage_map_locations.create(placename: placename)
      end
      coverage_map_location.geocode_from_placename_to_location
    end
    if coverage_map_locations.not_verified.any?
      changed = true
      coverage_map_locations.not_verified.destroy_all
    end
    reindex_record
  end

  private

  def reindex_record
    Sunspot.index!(record) if record.repository
  end

  def reindex_record_after_destroy
    if record.repository
      parent_record = record
      yield
      Sunspot.index!(parent_record)
    end
  end
end
