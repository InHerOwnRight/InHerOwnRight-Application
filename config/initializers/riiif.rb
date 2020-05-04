# frozen_string_literal: true

Riiif::Image.file_resolver = Spotlight::CarrierwaveFileResolver.new

# Riiif::Image.authorization_service = IIIFAuthorizationService

Riiif.not_found_image = 'app/assets/images/image_not_found.png'
#
Riiif::Engine.config.cache_duration = 365.days
