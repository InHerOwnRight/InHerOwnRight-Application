class Geocoder

  CACHE_FILE = "#{Rails.root}/tmp/geocoder_cache.yaml"

  def self.convert(placename)
    if Rails.env.development? || ENV['USE_AGGRESSIVE_GEOCODE_CACHEING']
      convert_with_aggressive_cacheing(placename)
    else
      convert_with_success_cacheing(placename)
    end
  end

  def self.convert_with_aggressive_cacheing(placename)
    # OsmApiCalls don't cache nil results, so this will save us a LOT of requests when loading and reloading data
    if cached_result = cache[placename]
      return cached_result 
    end

    result = cache[placename] = convert_with_success_cacheing(placename)
    write_cache_to_disk!

    return result
  end

  def self.convert_with_success_cacheing(placename)

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

  def self.cache
    @cache ||= YAML.load_file(CACHE_FILE)
  end

  def self.write_cache_to_disk!
    File.open(CACHE_FILE, 'w'){|f| f.write cache.to_yaml }
  end

  private_class_method :saved_osm_api_call
end
