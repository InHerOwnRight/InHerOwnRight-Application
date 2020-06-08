class GeocoderService
  def self.call_open_street_maps(placename)
    sanitized_placename = SpacialSanitizer.execute(placename)
    request = "https://nominatim.openstreetmap.org/search?format=json&q=#{sanitized_placename}"
    response = HTTParty.get(request)
    OsmApiCall.create(placename: placename, sanitized_placename: sanitized_placename, request: request, response: response)
  rescue => e
    raise "Open Maps API call failed: #{e}"
  end
end
