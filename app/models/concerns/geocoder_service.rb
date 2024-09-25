class GeocoderService
  def self.call_open_street_maps(placename)
    # Required by OSM: https://operations.osmfoundation.org/policies/nominatim/
    headers = { "User-Agent": "In Her Own Right"}

    sanitized_placename = SpacialSanitizer.execute(placename)
    begin
      request = "https://nominatim.openstreetmap.org/search?format=json&q=#{sanitized_placename}"
      response = HTTParty.get(request, headers: headers)
    rescue URI::InvalidURIError
      escaped_request = "https://nominatim.openstreetmap.org/search?format=json&q=#{URI.escape(sanitized_placename)}"
      response = HTTParty.get(escaped_request, headers: headers)
    end
    if !response.empty?
      OsmApiCall.create(placename: placename, sanitized_placename: sanitized_placename, request: request, response: response)
    else
      call_open_street_maps_without_string_shifting(placename)
    end
  end

  def self.call_open_street_maps_without_string_shifting(placename)
    # Required by OSM: https://operations.osmfoundation.org/policies/nominatim/
    headers = { "User-Agent": "In Her Own Right"}

    sanitized_placename = SpacialSanitizer.execute_without_string_shifting(placename)
    begin
      request = "https://nominatim.openstreetmap.org/search?format=json&q=#{sanitized_placename}"
      response = HTTParty.get(request, headers: headers)
    rescue URI::InvalidURIError
      escaped_request = "https://nominatim.openstreetmap.org/search?format=json&q=#{URI.escape(sanitized_placename)}"
      response = HTTParty.get(escaped_request, headers: headers)
    end
    OsmApiCall.create(placename: placename, sanitized_placename: sanitized_placename, request: request, response: response)
  end
end
