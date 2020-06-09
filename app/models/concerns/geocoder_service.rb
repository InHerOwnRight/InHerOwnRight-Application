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
    OsmApiCall.create(placename: placename, sanitized_placename: sanitized_placename, request: request, response: response)
  end
end
