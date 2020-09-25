desc 'Force geocode all location data to retrieve latitude and longitude of records in case sanitizer is updated'
task force_geocode_location_data: :environment do
  Record.all.each do |record|
    record.force_update_map_locations
  end
end
