class OsmApiCall < ActiveRecord::Base
  validates :placename, uniqueness: true
  validates :sanitized_placename, uniqueness: true

  def longitude_latitude
    json_response = JSON.parse(response)
    return if json_response.blank?

    first_response_match = json_response[0]
    longitude = first_response_match['lon'].to_d
    latitude = first_response_match['lat'].to_d
    [longitude, latitude]
  end
end
