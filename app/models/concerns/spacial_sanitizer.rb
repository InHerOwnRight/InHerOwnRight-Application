class SpacialSanitizer
  def self.execute(spacial)
    sanitized_spacial = spacial
    sanitized_spacial = sanitized_spacial.gsub(/\s+/, ' ')
    sanitized_spacial = sanitized_spacial.gsub(/\n/, ' ')
    sanitized_spacial = sanitized_spacial.gsub('(', '')
    sanitized_spacial = sanitized_spacial.gsub(')', '')
    sanitized_spacial = sanitized_spacial.gsub(';', '')
    sanitized_spacial = sanitized_spacial.gsub(';', '')
    sanitized_spacial
  end
end
