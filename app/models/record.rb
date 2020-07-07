class Record < ActiveRecord::Base
  extend FriendlyId
  friendly_id :oai_identifier, use: :slugged

  belongs_to :raw_record
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
  has_many :pacscl_collections, through: :dc_terms_is_part_ofs

  scope :for_repository, -> (repository) { joins(:raw_record).where(raw_records: {repository_id: repository.id} )}
  scope :for_same_creator, -> (creator_id) { joins(:dc_creators).where('dc_creators.id = ?', creator_id) }

  def is_collection?
    raw_record.record_type == "collection"
  end

  def list_pacscl_collection
    if is_collection?
      PacsclCollection.find_by_detailed_name(dc_titles.first.title)
    end
  end

  def list_records_for_collection
    if is_collection?
      PacsclCollection.find_by_detailed_name(dc_titles.first.title).records
    end
  end

  def thumbnail
    relative_path = super
    return nil unless relative_path

    "https://s3.us-east-2.amazonaws.com/pacscl-production#{relative_path}"
  end

  def repository_id
    repository.id
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

    boolean :exhibit_test_exhibit_public do
      true
    end

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
      repository.name
    end

    string :repository do
      repository.short_name
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

    text :title, stored: true do
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
      if pacscl_collections.any?
        pacscl_collections.map(&:detailed_name)
      elsif is_collection? && dc_titles.any?
        dc_titles.first.title
      end
    end

    string :pacscl_collection_clean_name, multiple: true do
      if pacscl_collections.any?
        pacscl_collections.map(&:clean_name)
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
        dc_creator = DcCreator.find_or_create_by(creator: creator)
        record_dc_creator = RecordDcCreatorTable.find_or_create_by(record_id: record.id, dc_creator_id: dc_creator.id)
      end
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

  def create_dc_terms_spacial(node, record)
    # hit map APIs here to get coordinates from spacial attribute
    dc_terms_spacial = DcTermsSpacial.find_or_create_by(record_id: record.id, spacial: node.text)
  end

  def create_dc_terms_is_part_of(node, record)
    if !node.text.empty?
      node.text.split(';').reject do |collection|
        collection.blank? || collection =~ /in her own right/i
      end.each do |collection|
        dc_terms_ipo = DcTermsIsPartOf.find_or_create_by(record_id: record.id, is_part_of: collection)
      end
    end
  end

  def create_full_text(node, record)
    full_text = FullText.find_or_create_by(record_id: record.id, transcription: node.text)
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
      dc_identifier = DcIdentifier.find_or_create_by(record_id: record.id, identifier: text)
    end
  end

  def actual_model_name(node_name)
    if node_name == "rights"
      @part_model_name = "dc_right"
    elsif node_name == "created"
      @part_model_name = "dc_date"
    elsif node_name == "licence"
      @part_model_name = "dc_right"
    else
      @part_model_name = "dc_#{node_name}"
    end
  end

  def create_dc_part(node_name, xml_doc, record)
    xml_doc.xpath("//#{node_name}").map do |node|

      if node_name == "creator" || node_name == "contributor"
        create_dc_creator(node, record)
      end

      if node_name == "identifier"
        create_dc_identifier(node, record)
      end

      if node_name == "type"
        create_dc_type(node, record)
      end

      if node_name == "subject"
        create_dc_subject(node, record)
      end

      if node_name == "date" || node_name == "created"
        create_dc_date(node, record)
      end

      if node_name == "extent"
        create_dc_terms_extent(node, record)
      end

      if node_name == "spacial" || node_name == "coverage" || node_name == "spatial"
        create_dc_terms_spacial(node, record)
      end

      if node_name == "isPartOf"
        create_dc_terms_is_part_of(node, record)
      end

      if node_name == "text" && !node.text.empty?
        create_full_text(node, record)
      end

      if node_name == "licence"
        node_name = "rights"
      end

      actual_model_name(node_name)

      modular_creators = ['dc_creator', 'dc_date', 'dc_type', 'dc_extent', 'dc_spatial', 'dc_text', 'dc_isPartOf', 'dc_identifier', 'dc_subject', 'dc_spacial']
      if !modular_creators.include?(@part_model_name)
        dc_model = "#{@part_model_name.camelize}".constantize.find_or_initialize_by(record_id: record.id)
        dc_model[node_name] = node.text
        dc_model.save
      end
    end
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["Repository Name", "Staging URL"]

      all.each do |record|
        csv << [record.repository.short_name, "http://pacscl.neomindlabs.com/records/#{record.slug}"]
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

########################## Oai API Endpoint ################################

  # def to_oai_dc
  #   OaiDcConverter.new(self).to_xml
  # end
end
