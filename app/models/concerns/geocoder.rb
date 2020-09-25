class Geocoder
  def self.convert(placename)
    sanitized_placename = SpacialSanitizer.execute(placename)
    osm_api_call = saved_osm_api_call(sanitized_placename)
    if osm_api_call
      osm_api_call&.longitude_latitude
    else
      sleep 2 unless Rails.env.test? # API caps user at 1 request per second, add buffer
      GeocoderService.call_open_street_maps(placename)
      saved_osm_api_call(sanitized_placename)&.longitude_latitude
    end
  end

  def self.saved_osm_api_call(sanitized_placename)
    OsmApiCall.find_by(sanitized_placename: sanitized_placename)
  end

  private_class_method :saved_osm_api_call
end
