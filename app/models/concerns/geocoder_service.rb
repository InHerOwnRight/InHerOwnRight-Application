class GeocoderService
  def self.call_open_street_maps(placename)
    sanitized_placename = SpacialSanitizer.execute(placename)
    begin
      request = "https://nominatim.openstreetmap.org/search?format=json&q=#{sanitized_placename}"
      response = HTTParty.get(request)
    rescue URI::InvalidURIError
      escaped_request = "https://nominatim.openstreetmap.org/search?format=json&q=#{URI.escape(sanitized_placename)}"
      response = HTTParty.get(escaped_request)
    end
    if response.any?
      OsmApiCall.create(placename: placename, sanitized_placename: sanitized_placename, request: request, response: response)
    else
      call_open_street_maps_without_string_shifting(placename)
    end
  end

  def self.call_open_street_maps_without_string_shifting(placename)
    sanitized_placename = SpacialSanitizer.execute_without_string_shifting(placename)
    begin
      request = "https://nominatim.openstreetmap.org/search?format=json&q=#{sanitized_placename}"
      response = HTTParty.get(request)
    rescue URI::InvalidURIError
      escaped_request = "https://nominatim.openstreetmap.org/search?format=json&q=#{URI.escape(sanitized_placename)}"
      response = HTTParty.get(escaped_request)
    end
    OsmApiCall.create(placename: placename, sanitized_placename: sanitized_placename, request: request, response: response)
  end
end
