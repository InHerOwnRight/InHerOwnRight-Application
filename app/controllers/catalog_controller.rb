# frozen_string_literal: true

##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include BlacklightRangeLimit::ControllerOverride
  include BlacklightMaps::Controller
  include Spotlight::Catalog
  helper Openseadragon::OpenseadragonHelper
  before_action :set_paper_trail_whodunnit


  before_action :extend_catalog_paginiation, only: [:index]
  # before_action :add_exhibit_filter
  # before_action :add_exhibit_tags

  def render_repository_name value
    value = Repository.find(value).name
  end
  helper_method :render_repository_name

  def render_collection_name value
    value = Record.find(value).dc_titles.first.title
  end
  helper_method :render_collection_name

  # copied from blacklight-maps gem in order to monkeypatch specific layout to force use of blacklight-maps leaflet 1.4 js file
  def map
    (@response, @document_list) = search_service.search_results
    params[:view] = 'maps'
    respond_to do |format|
      format.html
    end

    render layout: 'blacklight-maps/blacklight-maps'
  end

  # copied from blacklight gem in order to monkeypatch specific layout to force use of blacklight-maps leaflet 1.4 js file
  def index
    (@response, deprecated_document_list) = search_service.search_results

    @document_list = ActiveSupport::Deprecation::DeprecatedObjectProxy.new(deprecated_document_list, 'The @document_list instance variable is deprecated; use @response.documents instead.')

    respond_to do |format|
      format.html { store_preferred_view }
      format.rss  { render layout: false }
      format.atom { render layout: false }
      format.json do
        @presenter = Blacklight::JsonPresenter.new(@response,
                                                   blacklight_config)
      end
      additional_response_formats(format)
      document_export_formats(format)
    end

    render layout: 'blacklight-maps/blacklight-maps' if request.query_parameters[:view] == 'maps'
  end

  # extend results pagination if collection view
  def extend_catalog_paginiation
    if request.params["f"] && request.params["f"]["is_collection_id_i"]
      if request.params["f"]["is_collection_id_i"] == ["is_collection_id_i"]
        self.blacklight_config.per_page = [50, 100]
      end
    end
  end

  def add_exhibit_filter
    Spotlight::Exhibit.all.each do |exhibit|
      if request["f"] && !request["f"].include?("exhibit_#{exhibit.slug}_public_bsi")
        request["f"] << "exhibit_#{exhibit.slug}_public_bsi"
        self.solr_search_params_logic << request["f"]
      end
    end
  end

  def add_exhibit_tags
    Spotlight::Exhibit.all.each do |exhibit|
      if request["fq"] && !request["f"].include?("exhibit_#{exhibit.slug}_public_bsi")
        request["fq"] << "exhibit_#{exhibit.slug}_tags_ssim"
        self.solr_search_params_logic << request["fq"]
      end
    end
  end

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      qf: 'transcription^0.5',
      fl: '*',
      :'q.alt' => "*:*",
      :defType => 'edismax',
      :facet   => true,
      :fq => ["type:Record"]
    }

    ## Class for sending and receiving requests from a search index
   # config.repository_class = Blacklight::Solr::Repository

   # configurations added during upgrade to Blacklight v7.0.0
   config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

   config.add_results_collection_tool(:sort_widget)
   config.add_results_collection_tool(:per_page_widget)
   config.add_results_collection_tool(:view_type_group)

   config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
   config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
   config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
   config.add_show_tools_partial(:citation)

   config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
   config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')
   #
   ## Class for converting Blacklight's url parameters to into request parameters for the search index
   # config.search_builder_class = ::SearchBuilder
   #
   ## Model that maps search index responses to the blacklight response model
   # config.response_model = Blacklight::Solr::Response

   ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters

   # solr path which will be added to solr base url before the other solr params.
   #config.solr_path = 'select'

   # items to show per page, each number in the array represent another option to choose from.
   #config.per_page = [10,20,50,100]

   ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
   ## parameters included in the Blacklight-jetty document requestHandler.
   #
   #config.default_document_solr_params = {
   #  qt: 'document',
   #  ## These are hard-coded in the blacklight 'document' requestHandler
   #  # fl: '*',
   #  # rows: 1,
   #  # q: '{!term f=id v=$id}'
   #}


    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = :title_text

    config.add_sort_field 'relevance', sort: 'score desc', label: I18n.t('spotlight.search.fields.sort.relevance')

    config.add_field_configuration_to_solr_request!

    # solr field configuration for search results/index views
    # config.index.title_field = 'title_text'
    config.index.creator_field = 'creator_text'
    config.index.display_type_field = 'format'

    # config.index.title_field = 'title_display'
    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    # config.add_facet_field 'format', label: 'Format'
    # config.add_facet_field 'pub_date', label: 'Publication Year', single: true
    # config.add_facet_field 'rights_text', label: 'Rights', limit: 12
    # config.add_facet_field 'creator_s', {label: 'Creator'} do |field|
    #   raise field.solr_params
    # end
    # config.add_facet_field 'creator_s', label: 'Creator' do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
    #   field.solr_parameters = {
    #     qf: 'creator_text title_text description_text subject_text',
    #     fq: ["type:Record"],
    #     defType: "edismax"
    #     }
    #   end
    # config.add_facet_field 'creator_s', label: 'Creator'
    config.add_facet_field 'sort_creator_s', label: "Creator / Author", solr_params: { 'facet.mincount' => 1 }, limit: 100
    config.add_facet_field 'pub_date_im', label: 'Date Range', range: true, solr_params: { 'facet.mincount' => 1 }


    # config.add_facet_field 'repository_id_i', label: "Repository", helper_method: :render_repository_name


    config.add_facet_field 'subject_sm', label: "Subject", solr_params: { 'facet.mincount' => 1 }, limit: 200

    config.add_facet_field 'repository_s', label: "Contributing Institution", solr_params: { 'facet.mincount' => 1 }

    # enable facets:
    # https://github.com/projectblacklight/spotlight/issues/1812#issuecomment-327345318

    config.add_facet_field 'type_sm', label: "Type", solr_params: { 'facet.mincount' => 1 }

    config.add_facet_field 'is_collection_id_i', label: "Collections", query: {
     is_collection_id_i: { label: 'All Collections', fq: "is_collection_id_i:[1 TO *]" }
    }, show: false

    config.add_facet_field 'pacscl_collection_clean_name_sm', label: 'Collection', solr_params: { 'facet.mincount' => 1 }

    # config.add_facet_field 'subject_topic_facet', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    # config.add_facet_field 'language_facet', label: 'Language', limit: true
    # config.add_facet_field 'lc_1letter_facet', label: 'Call Number'
    # config.add_facet_field 'subject_geo_facet', label: 'Region'
    # config.add_facet_field 'subject_era_facet', label: 'Era'

    # config.add_facet_field 'example_pivot_field', label: 'Pivot Field', :pivot => ['rights_text', 'creator_text']

    # # Have BL send all facet field names to Solr, which has been the default
    # # previously. Simply remove these lines if you'd rather use Solr request
    # # handler defaults, or have no facets.

    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true

    # # solr fields to be displayed in the index (search results) view
    # #   The ordering of the field names is the order of the display
    # config.add_index_field 'title_display', label: 'Title'
    # config.add_index_field 'title_vern_display', label: 'Title'
    # config.add_index_field 'author_display', label: 'Author'
    # config.add_index_field 'author_vern_display', label: 'Author'
    # config.add_index_field 'format', label: 'Format'
    # config.add_index_field 'language_facet', label: 'Language'
    # config.add_index_field 'published_display', label: 'Published'
    # config.add_index_field 'published_vern_display', label: 'Published'
    # config.add_index_field 'lc_callnum_display', label: 'Call number'

    # # solr fields to be displayed in the show (single result) view
    # #   The ordering of the field names is the order of the display
    # config.add_show_field 'title_display', label: 'Title'
    # config.add_show_field 'title_vern_display', label: 'Title'
    # config.add_show_field 'subtitle_display', label: 'Subtitle'
    # config.add_show_field 'subtitle_vern_display', label: 'Subtitle'
    # config.add_show_field 'author_display', label: 'Author'
    # config.add_show_field 'author_vern_display', label: 'Author'
    # config.add_show_field 'format', label: 'Format'
    # config.add_show_field 'url_fulltext_display', label: 'URL'
    # config.add_show_field 'url_suppl_display', label: 'More Information'
    # config.add_show_field 'language_facet', label: 'Language'
    # config.add_show_field 'published_display', label: 'Published'
    # config.add_show_field 'published_vern_display', label: 'Published'
    # config.add_show_field 'lc_callnum_display', label: 'Call number'
    # config.add_show_field 'isbn_t', label: 'ISBN'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    # config.add_search_field 'all_fields', label: 'All Fields'


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    # config.add_search_field('title') do |field|
    #   # solr_parameters hash are sent to Solr as ordinary url query params.
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

    #   # :solr_local_parameters will be sent using Solr LocalParams
    #   # syntax, as eg {! qf=$title_qf }. This is neccesary to use
    #   # Solr parameter de-referencing like $title_qf.
    #   # See: http://wiki.apache.org/solr/LocalParams
    #   field.solr_local_parameters = {
    #     qf: '$title_qf',
    #     pf: '$title_pf'
    #   }
    # end

    # config.add_search_field('author') do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
    #   field.solr_local_parameters = {
    #     qf: '$author_qf',
    #     pf: '$author_pf'
    #   }
    # end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    # config.add_search_field('subject') do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
    #   field.qt = 'search'
    #   field.solr_local_parameters = {
    #     qf: '$subject_qf',
    #     pf: '$subject_pf'
    #   }
    # end

    config.add_search_field('all_fields', {label: "All Fields"}) do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.solr_parameters = { :'spellcheck.dictionary' => 'repository' }
      field.solr_parameters = {
        qf: 'creator_text title_text description_text subject_text repository_text full_text_text placename_search_text pacscl_collection_detailed_name_text'
        }
    end

    config.add_search_field('collection') do |field|
     field.solr_parameters = { qf: 'pacscl_collection_detailed_name_text'}
   end


    config.add_search_field('title') do |field|
     field.solr_parameters = { qf: 'title_text'}
    end

    config.add_search_field('creator') do |field|
     field.solr_parameters = { qf: 'creator_text'}
    end

    config.add_search_field('subject') do |field|
     field.solr_parameters = { qf: 'subject_text'}
    end

    config.add_search_field('type') do |field|
     field.solr_parameters = { qf: 'type_text'}
    end

    config.add_search_field('contributing_institution') do |field|
     field.solr_parameters = { qf: 'repository_text'}
    end


    config.add_search_field('transcription') do |field|
     field.solr_parameters = { qf: 'full_text_text' }
    end

    config.add_search_field('place') do |field|
      field.solr_parameters = { qf: 'placename_search_text' }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', label: 'relevance'
    # config.add_sort_field 'pub_date_sort desc, title_sort asc', label: 'year'
    config.add_sort_field 'score desc', label: 'Relevance'
    config.add_sort_field 'sort_title_s asc', label: 'Title A-Z'
    config.add_sort_field 'sort_title_s desc', label: 'Title Z-A'
    config.add_sort_field 'sort_creator_s asc', label: 'Creator A-Z'
    config.add_sort_field 'sort_creator_s desc', label: 'Creator Z-A'
    config.add_sort_field 'sort_date_d asc', label: 'Date: Oldest'
    config.add_sort_field 'sort_date_d desc', label: 'Date: Most Recent'

    # If there are more than this many search results, no spelling ("did yo
    # mean") suggestion is offered.
    # config.spell_max = 5

    # Configuration for autocomplete suggestor
    # config.autocomplete_enabled = true
    # config.autocomplete_path = 'suggest'

        # blacklight-maps configuration default values
    config.view.maps.geojson_field = "geojson_ssim"
    config.view.maps.placename_property = "placename"
    config.view.maps.coordinates_field = "location_rpt"
    config.view.maps.search_mode = "placename" # or "coordinates"
    config.view.maps.spatial_query_dist = 0.5
    config.view.maps.placename_field = "placename_sm"
    # config.view.maps.coordinates_facet_field = "location_rpt"
    config.view.maps.facet_mode = "geojson" # or "coordinates"
    config.view.maps.tileurl = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    config.view.maps.mapattribution = 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    config.view.maps.maxzoom = 18
    config.view.maps.show_initial_zoom = 5
    config.add_facet_field 'placename_sm', :label => 'Place', solr_params: { 'facet.mincount' => 1 }, limit: 200
    config.add_facet_field 'geojson_ssim', :limit => -2, :label => 'Coordinates', :show => false

    config.add_facet_fields_to_solr_request!

    config.add_field_configuration_to_solr_request!
  end
end
