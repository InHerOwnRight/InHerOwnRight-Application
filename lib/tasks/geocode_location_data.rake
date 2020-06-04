desc 'Geocode all location data to retrieve latitude and longitude of records'
task geocode_location_data: :environment do
  Record.all.each do |record|
    record.update_map_locations
  end
end
