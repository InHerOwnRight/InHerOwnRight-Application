require "csv"

module CsvHarvestHelper
  def self.initiate(harvest)
    CSV.foreach(harvest.attachment.path, headers: true) do |row|
      @repository = Repository.find_by_name(row[2])
      if @repository.nil?
        harvest.update(error: "Contributing repository (column 3) must match long repository name exactly.")
        harvest.update(status: 5)
        return
      end
    end
    self.delay(:queue => "csv_#{@repository.short_name.downcase.gsub(" ","_")}").create_raw_records(harvest)
    self.delay(:queue => "csv_#{@repository.short_name.downcase.gsub(" ","_")}").create_records(harvest) if harvest.error.nil?
    self.import_images(harvest) if harvest.error.nil?
    self.delay(:queue => "csv_#{@repository.short_name.downcase.gsub(" ","_")}").index_records(harvest) if harvest.error.nil?
  end

  def self.create_raw_records(harvest)
    harvest_date = harvest.created_at.strftime("%m_%d_%Y_%I_%M")
    name_spaces = {
        "xmlns:oai_qdc" => "http://worldcat.org/xmlschemas/qdc-1.0/",
        "xmlns:dcterms" => "http://purl.org/dc/terms/",
        "xmlns:dc"      => "http://purl.org/dc/elements/1.1/"
    }

    CSV.foreach(harvest.attachment.path, headers: true) do |row|
      raw_record = RawRecord.find_or_initialize_by(oai_identifier: row[0])
      @repository = Repository.find_by_name(row[2])
      raw_record.repository_id = @repository.id
      raw_record.original_record_url = row[1]
      raw_record.oai_identifier = row[0]
      raw_record.original_entry_date = harvest_date

      builder = Nokogiri::XML::Builder.new { |xml|
        xml.metadata {
          xml.contributing_repository row[2]
          xml['oai_qdc'].qualifieddc(name_spaces) do
            xml['dc'].identifier row[0]
            if row[1]
              xml['dc'].identifier row[1]
            end
            xml['dc'].title row[3]
            xml['dcterms'].created row[4]
            xml['dcterms'].created row[5]
            xml['dc'].creator row[6]
            xml['dcterms'].licence row[7]
            xml['dc'].identifier row[1]
            xml['dc'].type row[10]
            xml['dc'].language row[8]
            xml['dcterms'].extent row[11]
            if row[9] =~ /\;/
              subjects = row[9].split("; ")
              subjects.each do |subj|
                xml['dc'].subject subj
              end
            elsif row[9] =~ /\\|/
              subjects = row[9].split("|")
              subjects.each do |subj|
                xml['dc'].subject subj
              end
            else
              xml['dc'].subject row[9]
            end
            xml['dcterms'].spacial row[12]
            xml['dc'].description row[13]
            xml['dc'].publisher row[14]
            xml['dcterms'].isPartOf row[15]
            xml['dcterms'].text_ @full_text
            xml['dcterms'].localData row[17]
            xml['dcterms'].localData row[18]
            xml['dcterms'].localData row[19]
          end
        }
      }
      raw_record.xml_metadata = builder.to_xml
      raw_record.save
    end
  end

  def self.create_records(harvest)
    harvest.update(status: 1)
    raw_records = RawRecord.where(record_type: nil, updated_at: harvest.created_at..DateTime.now)
    raw_records.each do |raw_record|
      if !raw_record.xml_metadata.blank?
        record = Record.find_or_initialize_by(oai_identifier: raw_record.oai_identifier)
        record.raw_record = raw_record
        xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
        xml_doc.remove_namespaces!

        if record.save
          record.dc_types.each { |d| d.destroy }
          record.dc_subjects.each { |d| d.destroy }
          record.dc_dates.each { |d| d.destroy }
          record.dc_dates.each { |d| d.destroy }
          record.dc_titles.each { |t| t.destroy }
          record.dc_creators.each { |t| t.destroy }
          record.dc_rights.each { |t| t.destroy }
          record.dc_identifiers.each { |t| t.destroy }
          record.dc_terms_extents.each { |t| t.destroy }
          record.dc_terms_spacials.each { |t| t.destroy }
          record.dc_contributors.each { |t| t.destroy }
          record.dc_coverages.each { |t| t.destroy }
          record.dc_descriptions.each { |t| t.destroy }
          record.dc_abstracts.each { |t| t.destroy }
          record.dc_additional_descriptions.each { |t| t.destroy }
          record.dc_research_interests.each { |t| t.destroy }
          record.dc_formats.each { |t| t.destroy }
          record.dc_languages.each { |t| t.destroy }
          record.dc_publishers.each { |t| t.destroy }
          record.dc_relations.each { |t| t.destroy }
          record.dc_sources.each { |t| t.destroy }
          record.full_texts.each { |t| t.destroy }
          record.dc_terms_is_part_ofs.each { |t| t.destroy }
          record.spacial_map_locations.each { |t| t.destroy }
          record.coverage_map_locations.each { |t| t.destroy }

          node_names = ["title", "date", "creator", "subject", "format", "type", "language", "rights", "relation", "created", "licence", "identifier", "description", "contributor", "publisher", "extent", "source", "spatial", "text", "isPartOf", "coverage", "spacial"]
          node_names.each do | node_name |
            record.create_dc_part(node_name, xml_doc, record)
          end

          record.csv_harvests << harvest
          record.save
        end
      end
    end
  end

  def self.import_images(harvest)
    Delayed::Job.enqueue(DelayedRake.new("import_images:#{@repository.image_task}['#{harvest}']"), queue: "csv_#{@repository.short_name.downcase.gsub(" ","_")}")
    Delayed::Job.enqueue(DelayedRake.new("import_images:clean_up_collection_imgs"), queue: "csv_#{@repository.short_name.downcase.gsub(" ","_")}")
  end

  def self.index_records(harvest)
    harvest.update(status: 3)
    Sunspot.index!(harvest.records)
    harvest.update(status: 4)
  end
end
