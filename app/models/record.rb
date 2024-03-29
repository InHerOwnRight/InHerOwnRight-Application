class Record < ActiveRecord::Base
  extend FriendlyId
  friendly_id :oai_identifier, use: :slugged

  belongs_to :raw_record
  has_many :oai_harvest_records, dependent: :destroy
  has_many :oai_harvests, through: :oai_harvest_records
  has_many :csv_harvest_records, dependent: :destroy
  has_many :csv_harvests, through: :csv_harvest_records
  delegate :repository, to: :raw_record, allow_nil: true
  has_many :dc_contributors, dependent: :destroy
  has_many :dc_coverages, dependent: :destroy
  has_many :record_dc_creator_tables, dependent: :destroy
  has_many :dc_creators, through: :record_dc_creator_tables
  has_many :record_dc_type_tables, dependent: :destroy
  has_many :dc_types, through: :record_dc_type_tables
  has_many :record_dc_subject_tables, dependent: :destroy
  has_many :dc_subjects, through: :record_dc_subject_tables
  has_many :dc_dates, dependent: :destroy
  has_many :dc_descriptions, dependent: :destroy
  has_many :dc_abstracts, dependent: :destroy
  has_many :dc_additional_descriptions, dependent: :destroy
  has_many :dc_research_interests, dependent: :destroy
  has_many :dc_formats, dependent: :destroy
  has_many :dc_identifiers, dependent: :destroy
  has_many :dc_languages, dependent: :destroy
  has_many :dc_publishers, dependent: :destroy
  has_many :dc_relations, dependent: :destroy
  has_many :dc_rights, dependent: :destroy
  has_many :dc_sources, dependent: :destroy
  has_many :dc_titles, dependent: :destroy
  has_many :dc_terms_extents, dependent: :destroy
  has_many :dc_terms_spacials, dependent: :destroy
  has_many :full_texts, dependent: :destroy
  has_many :dc_terms_is_part_ofs, dependent: :destroy
  has_many :spacial_map_locations, through: :dc_terms_spacials, dependent: :destroy
  has_many :coverage_map_locations, through: :dc_coverages, dependent: :destroy

  scope :for_repository, -> (repository) { joins(:raw_record).where(raw_records: {repository_id: repository.id} )}
  scope :for_same_creator, -> (creator_id) { joins(:dc_creators).where('dc_creators.id = ?', creator_id) }

  delegate :s3_images_folder, to: :repository
  delegate :image_relevance_test, to: :repository

  def is_collection?
    raw_record.record_type == "collection" if raw_record
  end

  def pacscl_collection
   @pacscl_collection ||=  PacsclCollection.where("LOWER(detailed_name) = LOWER(?)", dc_titles.first.title).first
  end

  def pacscl_collection_exists?
    !!pacscl_collection
  end

  def list_pacscl_collection
    if is_collection? && pacscl_collection_exists?
      pacscl_collection
    end
  end

  def list_records_for_collection
    if is_collection? && pacscl_collection_exists?
      pacscl_collection.associated_records
    end
  end

  def thumbnail
    relative_path = super
    return nil unless relative_path

    "https://s3.us-east-2.amazonaws.com/pacscl-production#{relative_path}"
  end

  def repository_id
    repository.try(:id)
  end

  # def is_collection_id
  #   if is_collection?
  #     id
  #   else
  #     nil
  #   end
  # end

  def collection_repository_url
    if dc_identifiers.map{ |id| id.identifier_is_url? }.any?
      dc_identifiers.map do |id|
        if id.identifier_is_url?
          return id.identifier
          break
        end
      end
    else
      nil
    end
  end

  def all_creators
    creators = dc_creators.map(&:creator)
    contributors = dc_contributors.map(&:contributor)
    creators + contributors
  end

  def display_dates
    dates = []
    dc_dates.each do |d|
      if !dates.include?(d.unprocessed_date) && !d.unprocessed_date.nil?
        dates << d.unprocessed_date
      elsif d.unprocessed_date.nil?
        dates << d.english_date
      end
    end
    dates
  end

  searchable do

    text :oai_identifier

    text :coverage do
      dc_coverages.map(&:coverage)
    end

    text :spatial do
      dc_terms_spacials.map(&:spacial)
    end

    text :creator do
      dc_creators.map(&:creator)
    end

    text :identifier do
      dc_identifiers.map(&:identifier)
    end

    text :full_text do
      full_texts.map(&:transcription)
    end

    text :repository do
      repository.try(:name)
    end

    string :repository do
      repository.try(:short_name)
    end

    string :sort_creator do
      dc_creators.map(&:creator).first
    end

    date :sort_date do
      dc_dates.where.not(date: nil).order(:date).map(&:date).first
    end

    integer :repository_id, references: Repository

    integer :dc_type_ids, references: DcType, multiple: true

    string :subject, multiple: true do
      dc_subjects.map { |dc_subj| dc_subj.subject.slice(0,1).capitalize + dc_subj.subject.slice(1..-1) }
    end

    string :type, multiple: true do
      dc_types.map do |dc_type|
        dc_type.type.slice(0,1).capitalize + dc_type.type.slice(1..-1) if !dc_type.type.nil?
      end
    end

    integer :pub_date, multiple: true do
      years = dc_dates.where.not(date: nil).pluck(:date).map { |d| d.year }.sort
      years = (years[0]..years[-1]).to_a if years.present?
      years
    end

    text :description do
      dc_descriptions.map(&:description)
    end

    text :abstract do
      dc_abstracts.map(&:abstract)
    end

    text :additional_description do
      dc_additional_descriptions.map(&:additional_description)
    end

    text :research_interest do
      dc_research_interests.map(&:research_interest)
    end

    text :format do
      dc_formats.map(&:format)
    end

    text :language do
      dc_languages.map(&:language)
    end

    text :publisher do
      dc_publishers.map(&:publisher)
    end

    text :relation do
      dc_relations.map(&:relation)
    end

    text :rights do
      dc_rights.map(&:rights)
    end

    text :source do
      dc_sources.map(&:source)
    end

    text :subject do
      dc_subjects.map(&:subject)
    end

    text :title do
      dc_titles.map(&:title)
    end

    string :sort_title do
      dc_titles.map(&:title).first
    end

    text :type do
      dc_types.map(&:type)
    end

    location :location, multiple: true do
      lat = map_locations.map(&:latitude)
      lon = map_locations.map(&:longitude)
      Sunspot::Util::Coordinates.new("#{lat}, #{lon}")
    end

    string :geojson, multiple: true, as: :geojson_ssim do
      # remove the escape on the \n that is needed by blacklight-maps
      map_locations.map { |ml| ml.geojson_ssim.gsub("\\n", "\n") }
    end

    text :placename_search do
      map_locations.map(&:placename)
    end

    string :placename, multiple: true do
      map_locations.map(&:placename)
    end

    text :pacscl_collection_detailed_name do
      if associated_pacscl_collections.any?
        associated_pacscl_collections.map(&:detailed_name)
      elsif is_collection? && dc_titles.any?
        dc_titles.first.title
      end
    end

    string :pacscl_collection_clean_name, multiple: true do
      if associated_pacscl_collections.any?
        associated_pacscl_collections.map(&:clean_name)
      elsif is_collection? && dc_titles.any?
        collection_name = dc_titles.first.title
        collection = PacsclCollection.find_by(detailed_name: collection_name)
        collection.clean_name if collection
      end
    end

    string :is_collection do
      if is_collection?
        'true'
      else
        'false'
      end
    end
  end

########################## Record and record part creation ################################

  def create_dc_creator(node, record)
    if !node.text.blank?
      node.text.split("; ").each do |creator|
        stripped_creator = creator.gsub(" (Author)", "").gsub(" (Contributor)", "").gsub(" (Creator)", "")
        dc_creator = DcCreator.find_or_create_by(creator: stripped_creator)
        record_dc_creator = RecordDcCreatorTable.find_or_create_by(record_id: record.id, dc_creator_id: dc_creator.id)
      end
    end
  end

  def create_dc_creator_mods(node, record)
    if !node.text.blank?
      split_string = node.text.strip.split
      if ["author", "addressee", "creator", "contributor"].include?(split_string.last)
        role = split_string.last.insert(0, "(").insert(-1, ")")
        split_string.pop
        creator = (split_string << role).join(" ")
      else
        creator = split_string.join(" ")
      end

      dc_creator = DcCreator.find_or_create_by(creator: creator)
      record_dc_creator = RecordDcCreatorTable.find_or_create_by(record_id: record.id, dc_creator_id: dc_creator.id)
    end
  end

  def create_dc_subject(node, record)
    if node.text =~ /\;/
      subjects = node.text.split(";")
    else
      subjects = node.text.split("|")
    end
    stripped_subjects = subjects.map { |s| s.strip }
    stripped_subjects -= [""]
    stripped_subjects.each do |subject|
      dc_subject = DcSubject.find_or_create_by(subject: subject)
      record_dc_subject = RecordDcSubjectTable.find_or_create_by(record_id: record.id, dc_subject_id: dc_subject.id)
    end
  end

  def create_dc_language(node, record)
    if node.text.include?("\n")
      return
    elsif node.text =~ /\;/
      languages = node.text.split(";")
    else
      languages = node.text.split("|")
    end
    stripped_languages = languages.map { |s| s.strip }
    stripped_languages -= [""]
    stripped_languages.each do |language|
      dc_language = DcLanguage.find_or_create_by(language: language, record_id: record.id)
    end
  end

  def create_dc_type(node, record)
    if !node.text.blank?
      dc_type = DcType.find_or_create_by(type: node.text)
      record_dc_type = RecordDcTypeTable.find_or_create_by(record_id: record.id, dc_type_id: dc_type.id)
    end
  end

  def create_dc_date(node, record)
    raw_date = node.text
    dates = raw_date.split(";").map { |d| d.strip }.reject(&:empty?)
    split_dates = []
    dates.each do |d|
      date_remaining = d.scan(/\D/) - [" ", ","]
      if date_remaining.empty?
        split_dates << d.split(",").map { |d| d.strip }
      else
        split_dates << d
      end
    end
    split_dates.flatten!
    split_dates.each do |d|
      if d =~ /^\d{4}\-\d{2}\-\d{2}\ - \d{4}\-\d{2}\-\d{2}$/ || d =~ /^\d{4}\-\d{2}\-\d{2}\-\d{4}\-\d{2}\-\d{2}$/
        full_dates = d.split(" - ") if d =~ /^\d{4}\-\d{2}\-\d{2}\ - \d{4}\-\d{2}\-\d{2}$/
        full_dates = [d[0..9], d[11..-1]] if d =~ /^\d{4}\-\d{2}\-\d{2}\-\d{4}\-\d{2}\-\d{2}$/
        full_dates.each do |full_date|
          date_components = full_date.split("-")
          date = Date.new(date_components[0].to_i, date_components[1].to_i, date_components[2].to_i) if Date.valid_date?(date_components[0].to_i, date_components[1].to_i, date_components[2].to_i)
          dc_date = DcDate.find_or_initialize_by(record_id: record.id, date: date)
          dc_date.date = date
          dc_date.unprocessed_date = d
          dc_date.save
        end
      elsif d =~ /^\d{4}\-\d{2} - \d{4}\-\d{2}$/ || d =~ /^\d{4}\-\d{2}\-\d{4}\-\d{2}$/
        full_dates = d.split(" - ") if d =~ /^\d{4}\-\d{2} - \d{4}\-\d{2}$/
        full_dates = [d[0..6], d[8..-1]] if d =~ /^\d{4}\-\d{2}-\d{4}\-\d{2}$/
        full_dates.each do |full_date|
          date_components = full_date.split("-")
          date = Date.new(date_components[0].to_i, date_components[1].to_i)
          dc_date = DcDate.find_or_initialize_by(record_id: record.id, date: date)
          dc_date.unprocessed_date = d
          dc_date.save
        end
      elsif d =~ /^\d{4} - \d{4}$/ || d =~ /^\d{4}\-\d{4}$/
        years = d.split(" - ") if d =~ /^\d{4} - \d{4}$/
        years = d.split("-") if d =~ /^\d{4}\-\d{4}$/
        years.each do |year|
          date = Date.new(year.to_i)
          dc_date = DcDate.find_or_initialize_by(record_id: record.id, date: date)
          dc_date.unprocessed_date = d
          dc_date.save
        end
      elsif d =~ /^\d{4}\-\d{2}$/
        date_components = d.split("-")
        date = Date.new(date_components[0].to_i, date_components[1].to_i)
        dc_date = DcDate.find_or_initialize_by(record_id: record.id, date: date)
        dc_date.unprocessed_date = d
        dc_date.save
      elsif d =~ /^\d{4}$/
        date = Date.new(d.to_i)
        dc_date = DcDate.find_or_initialize_by(record_id: record.id, date: date)
        dc_date.unprocessed_date = d
        dc_date.save
      else
        begin
          date = Date.parse(d)
          dc_date = DcDate.find_or_initialize_by(record_id: record.id, date: date)
          dc_date.unprocessed_date = d
          dc_date.save
        rescue
          dc_date = DcDate.find_or_initialize_by(record_id: record.id, english_date: d)
          dc_date.save
        end
      end
    end
  end

  def create_dc_terms_extent(node, record)
    dc_terms_extent = DcTermsExtent.find_or_create_by(record_id: record.id, extent: node.text)
  end

  def is_unwanted_spacial_term?(node_text)
    /\A\s*(North and Central America|Europe|Asia|Africa)--/.match(node_text)
  end

  def create_dc_terms_spacial(node, record)
    # hit map APIs here to get coordinates from spacial attribute
    return nil if is_unwanted_spacial_term?(node.text)
    dc_terms_spacial = DcTermsSpacial.find_or_create_by(record_id: record.id, spacial: node.text)
  end

  def create_dc_coverage(node, record)
    return nil if is_unwanted_spacial_term?(node.text)
    dc_coverage = DcCoverage.find_or_initialize_by(record_id: record.id, coverage: node.text)
    dc_coverage.save!
  end

  def create_dc_terms_is_part_of(node, record)
    if !node.text.empty?
      node.text.split(';').reject do |collection|
        collection.blank? || collection =~ /in her own right/i
      end.each do |collection|
        dc_terms_ipo = DcTermsIsPartOf.find_or_create_by(record_id: record.id, is_part_of: sanitize(collection))
      end
    end
  end

  def create_full_text(node, record)
    full_text = FullText.find_or_create_by(record_id: record.id, transcription: node.text)
  end

  def create_dc_description(node, record)
    if !node.text.empty?
      DcDescription.find_or_create_by(record_id: record.id, description: node.text)
    end
  end

  def create_dc_identifier(node, record)
    if !node.text.blank?
      if node.text =~ /;$/
        text = node.text.split(";").first
      elsif node.text =~ /^\s/
        text = node.text.split(" ").last
      else
        text = node.text
      end
      text = text.gsub(/^local:\s*/, '')
      dc_identifier = DcIdentifier.find_or_create_by(record_id: record.id, identifier: text)
    end
  end

  def create_dc_part(node_name, xml_doc, filters = {})
    if filter = filters[node_name]
      xpath
    end
    record = self
    xml_doc.xpath("//#{node_name}").map do |node|
      if node_name == "creator"
        create_dc_creator(node, record)
      end

      if node_name == "name"
        create_dc_creator_mods(node, record)
      end

      if node_name == "identifier" || node_name == "identifier.url"
        create_dc_identifier(node, record)
      end

      if node_name == "type" || node_name == "typeOfResource" || node_name == "genre"
        create_dc_type(node, record)
      end

      if node_name == "subject"
        create_dc_subject(node, record)
      end

      if node_name == "language" || node_name == "language/languageTerm"
        create_dc_language(node, record)
      end

      if node_name == "date" || node_name == "created" || node_name == "dateCreated"
        create_dc_date(node, record)
      end

      if node_name == "extent"
        create_dc_terms_extent(node, record)
      end

      if node_name == "spacial" || node_name == "coverage" || node_name == "spatial" || node_name == "geographic"
        create_dc_terms_spacial(node, record)
      end

      if node_name == "isPartOf" || node_name == "relatedItem/titleInfo"
        create_dc_terms_is_part_of(node, record)
      end

      if node_name == "text" && !node.text.empty?
        create_full_text(node, record)
      end

      if node_name == "description"
        create_dc_description(node, record)
      end

      if node_name == "coverage"
        create_dc_coverage(node, record)
      end

      node_name_dictionary = {"licence" => "rights", "accessCondition" => "rights", "mods/titleInfo" => "title",
        "relatedItem/titleInfo" => "isPartOf", "language/languageTerm" => "language"}

      node_name = node_name_dictionary[node_name] || node_name

      part_model_name_dictionary = {"rights" => "dc_right", "created" => "dc_date", "licence" => "dc_right"}
      part_model_name = part_model_name_dictionary[node_name] || "dc_#{node_name}"

      modular_creators = ['dc_creator', 'dc_date', 'dc_type', 'dc_extent', 'dc_spatial', 'dc_spacial', 'dc_text', 'dc_isPartOf', 'dc_identifier', 'dc_identifier.url', 'dc_subject', 'dc_description', 'dc_typeOfResource', 'dc_genre','dc_dateCreated', 'dc_name', 'dc_language', 'dc_geographic', 'dc_coverage']
      if !modular_creators.include?(part_model_name)
        dc_model = "#{part_model_name.camelize}".constantize.find_or_initialize_by(record_id: record.id)
        dc_model[node_name] = sanitize(node.text)
        dc_model.save
      end
    end
  end

  def sanitize(text)
    text.strip
  end

  def self.create_from_raw_record(raw_record, filters = { })
    return if raw_record.xml_metadata.blank?
    record = find_or_initialize_by(oai_identifier: raw_record.oai_identifier)
    record.raw_record_id = raw_record.id
    xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
    xml_doc.remove_namespaces!

    if record.save
      node_names = ["title", "mods/titleInfo", "date", "dateCreated", "creator", "name", "subject", "format", "type",
                      "typeOfResource", "genre", "language", "language/languageTerm", "rights", "accessCondition",
                      "relation", "created", "licence", "identifier", "description", "abstract", "contributor",
                      "publisher", "extent", "source", "spatial", "geographic", "text", "isPartOf",
                      "relatedItem/titleInfo", "coverage", "spacial", "identifier.url"]

      node_names.each do | node_name |
        record.create_dc_part(node_name, xml_doc, filters)
      end
      record.reload
    end
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["Repository Name", "Staging URL"]

      all.each do |record|
        csv << [record.repository.try(:short_name), "http://pacscl.neomindlabs.com/records/#{record.slug}"]
      end
    end
  end

  def map_locations
    map_locations = spacial_map_locations + coverage_map_locations
    placenames = []
    map_locations.select do |map_location|
      if !placenames.include?(map_location.placename) && map_location.saved_coords?
        placenames << map_location.placename
        map_location
      end
    end
  end

  def update_map_locations
    dc_terms_spacials.each do |dc_terms_spacial|
      dc_terms_spacial.update_map_locations
    end
    dc_coverages.each do |dc_coverage|
      dc_coverage.update_map_locations
    end
  end

  def force_update_map_locations
    dc_terms_spacials.each do |dc_terms_spacial|
      dc_terms_spacial.force_update_map_locations
    end
    dc_coverages.each do |dc_coverage|
      dc_coverage.force_update_map_locations
    end
  end

  def associated_pacscl_collections
    is_part_of_pacscl_collections = dc_terms_is_part_ofs.map { |dtipo| dtipo.pacscl_collection }
    relation_pacscl_collections = dc_relations.map{ |drc| drc.pacscl_collection }

    combined_pacscl_collections = is_part_of_pacscl_collections + relation_pacscl_collections
    combined_pacscl_collections.compact.uniq
  end

########################## Oai API Endpoint ################################

  def to_oai_dc
    OaiDcConverter.new(self).to_xml
  end
######################## End Oai API Endpoint ###############################

  def rescan_images!
    self.dc_identifiers.each do |dc_identifier|
      all_s3_image_paths.each do |image_path|
        if image_relevance_test.call(self, image_path, dc_identifier)
          if /_thumb.png\Z/.match(image_path)
            self.thumbnail = "/#{image_path}"
          elsif /_lg.png\Z/.match(image_path)
            self.file_name = "/#{image_path}"
          end
          self.save!
        end
      end # all_potential_image_paths.each
    end # self.dc_identifiers.each
  end

  protected

  def all_s3_image_paths
    region = 'us-east-2'
    s3 = Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    bucket = s3.bucket('pacscl-production')

    s3_base = "images/#{s3_images_folder}"
    all_repo_paths = bucket.objects(prefix: s3_base).collect(&:key)
    archive_paths = bucket.objects(prefix: "#{s3_base}/Archive").collect(&:key)
    failed_paths = bucket.objects(prefix: "#{s3_base}/Failed\ Inbox").collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
  end
end
