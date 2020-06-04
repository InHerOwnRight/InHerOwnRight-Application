class Geocoder
  def self.convert(placename)
    sanitized_placename = SpacialSanitizer.execute(placename)
    unless api_call_coordinates(sanitized_placename)
      sleep 2 unless Rails.env.test? # API caps user at 1 request per second, add buffer
      GeocoderService.call_open_street_maps(placename)
    end
    api_call_coordinates(sanitized_placename)
  end

  def self.api_call_coordinates(sanitized_placename)
    OsmApiCall.find_by(sanitized_placename: sanitized_placename)&.longitude_latitude
  end

  private_class_method :api_call_coordinates
end
