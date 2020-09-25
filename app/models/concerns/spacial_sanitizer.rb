class SpacialSanitizer
  ABBREVIATIONS_MAP = {
    # US postal abbreviations
    'al' => 'alabama',
    'ak' => 'alaska',
    'az' => 'arizona',
    'ar' => 'arkansas',
    'ca' => 'california',
    'co' => 'colorado',
    'ct' => 'connecticut',
    'de' => 'delaware',
    'fl' => 'florida',
    'ga' => 'georgia',
    'hi' => 'hawaii',
    'id' => 'idaho',
    'il' => 'illinois',
    'in' => 'indiana',
    'ia' => 'iowa',
    'ks' => 'kansas',
    'ky' => 'kentucky',
    'la' => 'louisiana',
    'me' => 'maine',
    'md' => 'maryland',
    'ma' => 'massachusetts',
    'mi' => 'michigan',
    'mn' => 'minnesota',
    'ms' => 'mississippi',
    'mo' => 'missouri',
    'mt' => 'montana',
    'ne' => 'nebraska',
    'nv' => 'nevada',
    'nh' => 'new hampshire',
    'nj' => 'new jersey',
    'nm' => 'new mexico',
    'ny' => 'new york',
    'nc' => 'north carolina',
    'nd' => 'north dakota',
    'oh' => 'ohio',
    'ok' => 'oklahoma',
    'or' => 'oregon',
    'pa' => 'pennsylvania',
    'ri' => 'rhode island',
    'sc' => 'south carolina',
    'sd' => 'south dakota',
    'tn' => 'tennessee',
    'tx' => 'texas',
    'ut' => 'utah',
    'vt' => 'vermont',
    'va' => 'virginia',
    'wa' => 'washington',
    'wv' => 'west virginia',
    'wi' => 'wisconsin',
    'wy' => 'wyoming',
    # US commonwealth and territory postal abbreviatoins
    'as' => 'american samoa',
    'dc' => 'district of columbia',
    'fm' => 'federated states of micronesia',
    'gu' => 'guam',
    'mh' => 'marshall islands',
    'mp' => 'northern mariana islands',
    'pw' => 'palau',
    'pr' => 'puerto rico',
    'vi' => 'virgin islands',
    # US typical abbreviations
    'ala' => 'alabama',
    'ariz' => 'arizona',
    'ark' => 'arkansas',
    'calif' => 'california',
    'colo' => 'colorado',
    'conn' => 'connecticut',
    'del' => 'delaware',
    'fla' => 'florida',
    'ill' => 'illinois',
    'ind' => 'indiana',
    'iowa' => 'iowa',
    'kans' => 'kansas',
    'maine' => 'maine',
    'mass' => 'massachusetts',
    'mich' => 'michigan',
    'minn' => 'minnesota',
    'miss' => 'mississippi',
    'mont' => 'montana',
    'neb' => 'nebraska',
    'nebr' => 'nebraska',
    'nev' => 'nevada',
    'nmex' => 'new mexico',
    'ndak' => 'north dakota',
    'okla' => 'oklahoma',
    'ore' => 'oregon',
    'oreg' => 'oregon',
    'sdak' => 'south dakota',
    'tenn' => 'tennessee',
    'tex' => 'texas',
    'utah' => 'utah',
    'wash' => 'washington',
    'wva' => 'west virginia',
    'wis' => 'wisconsin',
    'wisc' => 'wisconsin',
    'wyo' => 'wyoming',
    # country abbreviations
    'usa' => 'united states',
    'us' => 'united states',
    'uk' => 'united kingdom'
  }

  COUNTRIES = [
    'afghanistan',
    'akrotiri',
    'albania',
    'algeria',
    'american samoa',
    'andorra',
    'angola',
    'anguilla',
    'antarctica',
    'antarctic lands',
    'antigua',
    'argentina',
    'armenia',
    'aruba',
    'ashmore',
    'australia',
    'austria',
    'azerbaijan',
    'bahamas',
    'bahrain',
    'bangladesh',
    'barbados',
    'barbuda',
    'bassas da india',
    'belarus',
    'belgium',
    'belize',
    'benin',
    'bermuda',
    'bhutan',
    'bolivia',
    'bosnia',
    'botswana',
    'bouvet island',
    'brazil',
    'british indian ocean territory',
    'british virgin islands',
    'brunei',
    'bulgaria',
    'burkina faso',
    'burma',
    'burundi',
    'cambodia',
    'cameroon',
    'caicos islands',
    'canada',
    'cape verde',
    'cartier islands',
    'cayman islands',
    'central african republic',
    'chad',
    'chile',
    'china',
    'christmas island',
    'clipperton island',
    'cocos (keeling) islands',
    'colombia',
    'comoros',
    'cook islands',
    'coral sea islands',
    'costa rica',
    "cote d'ivoire",
    'croatia',
    'cuba',
    'cyprus',
    'czech republic',
    'democratic republic of the congo',
    'denmark',
    'dhekelia',
    'djibouti',
    'dominica',
    'dominican republic',
    'ecuador',
    'egypt',
    'el salvador',
    'equatorial guinea',
    'eritrea',
    'estonia',
    'ethiopia',
    'europa island',
    'falkland islands',
    'faroe islands',
    'federated states of micronesia',
    'fiji',
    'finland',
    'france',
    'french guiana',
    'french polynesia',
    'french southern',
    'futuna',
    'gabon',
    'gambia',
    'gaza strip',
    'georgia',
    'germany',
    'ghana',
    'gibraltar',
    'glorioso islands',
    'greece',
    'greenland',
    'grenada',
    'guadeloupe',
    'guam',
    'guatemala',
    'guernsey',
    'guinea',
    'guinea-bissau',
    'guyana',
    'haiti',
    'heard island',
    'herzegovina',
    'holy see',
    'honduras',
    'hong kong',
    'hungary',
    'iceland',
    'india',
    'indonesia',
    'iran',
    'iraq',
    'ireland',
    'islas malvinas',
    'isle of man',
    'israel',
    'italy',
    'jamaica',
    'jan mayen',
    'japan',
    'jersey',
    'jordan',
    'juan de nova island',
    'kazakhstan',
    'kenya',
    'kiribati',
    'kuwait',
    'kyrgyzstan',
    'laos',
    'latvia',
    'lebanon',
    'lesotho',
    'liberia',
    'libya',
    'liechtenstein',
    'lithuania',
    'luxembourg',
    'macau',
    'macedonia',
    'madagascar',
    'malawi',
    'malaysia',
    'maldives',
    'mali',
    'malta',
    'marshall islands',
    'martinique',
    'mauritania',
    'mauritius',
    'mayotte',
    'mcdonald islands',
    'mexico',
    'micronesia',
    'miquelon',
    'moldova',
    'monaco',
    'mongolia',
    'montserrat',
    'morocco',
    'mozambique',
    'namibia',
    'nauru',
    'navassa island',
    'nepal',
    'netherlands',
    'netherlands antilles',
    'new caledonia',
    'new zealand',
    'nevis',
    'nicaragua',
    'niger',
    'nigeria',
    'niue',
    'norfolk island',
    'northern mariana islands',
    'north korea',
    'norway',
    'oman',
    'pakistan',
    'palau',
    'panama',
    'papua new guinea',
    'paracel islands',
    'paraguay',
    'peru',
    'philippines',
    'pitcairn islands',
    'poland',
    'portugal',
    'puerto rico',
    'qatar',
    'republic of the congo',
    'reunion',
    'romania',
    'russia',
    'rwanda',
    'saint helena',
    'saint kitts',
    'saint lucia',
    'saint pierre',
    'saint vincent and the grenadines',
    'samoa',
    'san marino',
    'sao tome and principe',
    'saudi arabia',
    'senegal',
    'serbia and montenegro',
    'seychelles',
    'sierra leone',
    'singapore',
    'slovakia',
    'slovenia',
    'solomon islands',
    'somalia',
    'south africa',
    'south georgia',
    'south sandwich islands',
    'spain',
    'spratly islands',
    'sri lanka',
    'sudan',
    'suriname',
    'svalbard',
    'swaziland',
    'sweden',
    'switzerland',
    'syria',
    'taiwan',
    'tajikistan',
    'tanzania',
    'thailand',
    'timor-leste',
    'tobago',
    'togo',
    'tokelau',
    'tonga',
    'trinidad',
    'tromelin island',
    'tunisia',
    'turkey',
    'turkmenistan',
    'turks',
    'tuvalu',
    'uganda',
    'ukraine',
    'united arab emirates',
    'united kingdom',
    'united states',
    'united states of america',
    'uruguay',
    'uzbekistan',
    'vanuatu',
    'vatican city',
    'venezuela',
    'vietnam',
    'virgin islands',
    'wake island',
    'wallis',
    'west bank',
    'western sahara',
    'yemen',
    'zambia',
    'zimbabwe'
  ]

  def self.execute(spacial)
    sanitizing_spacial = spacial
    sanitizing_spacial = sanitizing_spacial.downcase
    sanitizing_spacial = remove_special_characters(sanitizing_spacial)
    sanitizing_spacial = identify_and_remove_abbreviations(sanitizing_spacial)
    sanitizing_spacial = identify_and_remove_country(sanitizing_spacial)
    sanitizing_spacial = frontload_abbreviations(sanitizing_spacial)
    sanitizing_spacial = frontload_country(sanitizing_spacial)
    sanitized_spacial  = remove_extra_spaces(sanitizing_spacial)
    sanitized_spacial
  end

  def self.execute_without_string_shifting(spacial)
    sanitizing_spacial = spacial
    sanitizing_spacial = sanitizing_spacial.downcase
    sanitizing_spacial = remove_special_characters(sanitizing_spacial)
    sanitizing_spacial = unabbreviate_abbreviations(sanitizing_spacial)
    sanitized_spacial  = remove_extra_spaces(sanitizing_spacial)
    sanitized_spacial
  end

  private

  def self.remove_special_characters(spacial)
    sanitizing_spacial = spacial
    sanitizing_spacial = sanitizing_spacial.gsub(/\n/, ' ')
    sanitizing_spacial = sanitizing_spacial.gsub('(', '')
    sanitizing_spacial = sanitizing_spacial.gsub(')', '')
    sanitizing_spacial = sanitizing_spacial.gsub('.', '')
    sanitizing_spacial = sanitizing_spacial.gsub(' : Town', '')
    sanitized_spacial = sanitizing_spacial.gsub(';', '')
    sanitized_spacial
  end
  
  def self.identify_and_remove_abbreviations(spacial)
    sanitizing_spacial = spacial
    @unabbreviated_matches = []
    abbreviations = ABBREVIATIONS_MAP.keys
    spacial_words = sanitizing_spacial.split(" ")
    abbreviations_in_spacial = abbreviations & spacial_words
    if abbreviations_in_spacial.any?
      abbreviations_in_spacial.each do |abbreviation_in_spacial|
        unabbreviated = ABBREVIATIONS_MAP[abbreviation_in_spacial]
        @unabbreviated_matches << unabbreviated
        sanitizing_spacial = sanitizing_spacial.gsub(abbreviation_in_spacial, '')
      end
    end
    sanitized_spacial = sanitizing_spacial
    sanitized_spacial
  end

  def self.unabbreviate_abbreviations(spacial)
    sanitizing_spacial = spacial
    @unabbreviated_matches = []
    abbreviations = ABBREVIATIONS_MAP.keys
    spacial_words = sanitizing_spacial.split(" ")
    abbreviations_in_spacial = abbreviations & spacial_words
    if abbreviations_in_spacial.any?
      abbreviations_in_spacial.each do |abbreviation_in_spacial|
        unabbreviated = ABBREVIATIONS_MAP[abbreviation_in_spacial]
        sanitizing_spacial = sanitizing_spacial.gsub(abbreviation_in_spacial, unabbreviated)
      end
    end
    sanitized_spacial = sanitizing_spacial
    sanitized_spacial
  end
    
  def self.identify_and_remove_country(spacial)
    sanitizing_spacial = spacial
    @country_match = nil
    COUNTRIES.each do |country|
      @country_match = country if sanitizing_spacial.include?(country)
    end
    if @country_match
      sanitizing_spacial = sanitizing_spacial.gsub(@country_match, '')
    elsif !@country_match && @unabbreviated_matches.any? # check if country was removed with abbreviations
      @unabbreviated_matches.each do |unabbreviated_match|
        @country_match = unabbreviated_match if COUNTRIES.include?(unabbreviated_match)
      end
      if @country_match
        @unabbreviated_matches.delete(@country_match)
      else # if country still not found but abbreviations were found then means it is in USA
        @country_match = 'united states'
      end
    end
    sanitized_spacial = sanitizing_spacial
    sanitized_spacial
  end

  def self.frontload_abbreviations(spacial)
    sanitizing_spacial = spacial
    if @unabbreviated_matches.any?
      @unabbreviated_matches.reverse.each do |unabbreviated_match| # use resevere to add back in with original order
        sanitizing_spacial = sanitizing_spacial.prepend("#{unabbreviated_match} ")
      end
    end
    sanitized_spacial = sanitizing_spacial
    sanitized_spacial
  end

  def self.frontload_country(spacial)
    sanitizing_spacial = spacial
    if @country_match
      sanitizing_spacial = sanitizing_spacial.prepend("#{@country_match} ")
    end
    sanitized_spacial = sanitizing_spacial
    sanitized_spacial
  end

  def self.remove_extra_spaces(spacial)
    sanitizing_spacial = spacial
    sanitizing_spacial = sanitizing_spacial.gsub('  ', ' ')
    sanitized_spacial  = sanitizing_spacial.strip
    sanitized_spacial
  end
end
