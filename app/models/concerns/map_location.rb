module MapLocation
  extend ActiveSupport::Concern

  included do
    before_save :update_blacklight_location_attributes, unless: :new_record?

    scope :not_geocoded, -> { where(geocode_attempt: nil) }
    scope :not_verified, -> { where(verified: nil) }
  end

  def geocode_from_placename_to_location
    update_column('geocode_attempt', DateTime.now)
    if coords_in_placename
      save_coords_from_placename
    else
      coordinates = Geocoder.convert(placename)
      update_attributes(longitude: coords_to_longitude(coordinates), latitude: coords_to_latitude(coordinates)) if coordinates
    end
  end

  def coords_in_placename
    no_spaces_spacial = placename.gsub(" ", ",").gsub(/,+/, ",")
    # matches anything like coords 34.1012,-43.123 or 34.1012,,,-43.123 due to spaces to commas above
    no_spaces_spacial.scan(/\-?[0-9]+\.[0-9]+\,+\-?[0-9]+\.[0-9]+/).first
  end

  def save_coords_from_placename
    coord_one = coords_in_placename.split(",").first.to_d
    coord_two = coords_in_placename.split(",").last.to_d
    if larger_than_90?(coord_one)
      longitude = coord_one
      latitude = coord_two
    else
      latitude = coord_one
      longitude = coord_two
    end
    update_attributes(longitude: longitude, latitude: latitude)
  end

  def saved_coords?
    longitude && latitude && geojson_ssim
  end

  private
    def larger_than_90?(number)
      number.abs() > 90
    end

    def coords_to_longitude(coordinates)
      coordinates.first
    end

    def coords_to_latitude(coordinates)
      coordinates.last
    end

    def update_blacklight_location_attributes
      if (longitude_changed? || latitude_changed?)
        update_location_rpt
        update_geojson_ssim
      end
      update_geojson_ssim if (placename_changed? && !placename.nil?)
    end

    def update_location_rpt
      update_column('location_rpt', "#{longitude}, #{latitude}")
    end

    def update_geojson_ssim
      # blacklight-maps will error on JSON parse if \n is not escaped
      updated_placename = placename.gsub("\n", "\\n")
      new_geojson_value = "{\"type\": \"Feature\", \"geometry\": {\"type\": \"Point\", \"coordinates\": [#{longitude}, #{latitude}]}, \"properties\": {\"placename\": \"#{updated_placename}\"}}"
      update_column('geojson_ssim', new_geojson_value)
    end
end