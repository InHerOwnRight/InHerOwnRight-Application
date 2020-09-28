desc 'Force geocode all location data to retrieve latitude and longitude of records in case sanitizer is updated'
task force_geocode_location_data: :environment do
  remaining_records = Record.count
  Record.all.each_with_index do |record, i|
    remaining_records -= 1
    puts "Updating geolocation for record id #{record.id}. #{remaining_records} records remaining"
    puts "#{remaining_records} records remaining"
    record.force_update_map_locations
  end
end
