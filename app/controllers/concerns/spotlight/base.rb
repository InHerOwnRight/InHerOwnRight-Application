# frozen_string_literal: true

module Spotlight
  ##
  # Base controller mixin
  module Base
    extend ActiveSupport::Concern

    include Blacklight::Base
    include Spotlight::Config

    included do
      helper_method :controller_tracking_method
    end

    def controller_tracking_method
      Spotlight::Engine.config.controller_tracking_method
    end

    # This overwrites Blacklight::Configurable#blacklight_config
    # def blacklight_config
    #   exhibit_specific_blacklight_config
    # end

    def autocomplete_json_response(document_list)
      if document_list.any?
        document_list.map do |doc|
          autocomplete_json_response_for_document doc
        end
      end
    end

    # rubocop:disable Metrics/AbcSize
    def autocomplete_json_response_for_document(doc)
      id = doc.id.scan(/\d+/).first.to_i
      record = Record.find(id)
      {
        id: id,
        title: record.dc_titles.first.title,
        thumbnail: "https://s3.us-east-2.amazonaws.com/pacscl-production#{record.thumbnail}",
        slug: record.slug,
        full_image_url: record.file_name,
        url: polymorphic_path([current_exhibit, doc]),
        private: doc.private?(current_exhibit),
        global_id: doc.to_global_id.to_s,
        iiif_manifest: doc[Spotlight::Engine.config.iiif_manifest_field]
      }
    end
    # rubocop:enable Metrics/AbcSize
  end
end
