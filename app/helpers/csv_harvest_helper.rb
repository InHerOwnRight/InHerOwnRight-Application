require "csv"
require 'aws-sdk-s3'

module CsvHarvestHelper
  def self.initiate(harvest)
    begin
      CSV.parse(harvest.csv_file.download, headers: true) do |row|
        unless row[0].nil?
          @repository = Repository.find_by_name(row[2])
          if @repository.nil?
            harvest.update(error: "Contributing repository (column 3) must match long repository name exactly.")
            harvest.update(status: 5)
            return
          else
            harvest.update(repository_id: @repository.id)
          end
        end
      end
    rescue => e
      harvest.update(status: 5, error: "Failed to parse CSV: #{e.message}")
    end
     if @repository
      self.delay(:queue => "csv_#{@repository.short_name.downcase.gsub(" ","_")}").create_raw_records(harvest) if harvest.error.nil?
      self.delay(:queue => "csv_#{@repository.short_name.downcase.gsub(" ","_")}").create_records(harvest) if harvest.error.nil?
      self.delay(:queue => "csv_#{@repository.short_name.downcase.gsub(" ","_")}").import_images(harvest) if harvest.error.nil?
      self.delay(:queue => "csv_#{@repository.short_name.downcase.gsub(" ","_")}").index_records(harvest) if harvest.error.nil?
    end
  end

  def self.create_raw_records(harvest)
    begin
      harvest_date = harvest.created_at.strftime("%m_%d_%Y_%I_%M")
      name_spaces = {
          "xmlns:oai_qdc" => "http://worldcat.org/xmlschemas/qdc-1.0/",
          "xmlns:dcterms" => "http://purl.org/dc/terms/",
          "xmlns:dc"      => "http://purl.org/dc/elements/1.1/"
      }

      CSV.parse(harvest.csv_file.download, headers: true) do |row|
        unless row[0].nil?
          raw_record = RawRecord.find_or_initialize_by(oai_identifier: row[0])
          @repository = Repository.find_by_name(row[2])
          raw_record.repository_id = @repository.id
          raw_record.original_record_url = row[1]
          raw_record.oai_identifier = row[0]
          raw_record.original_entry_date = harvest_date
          raw_record.harvest_id = harvest.id

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
                xml['dc'].description row[16]
              end
            }
          }
          raw_record.xml_metadata = builder.to_xml
          raw_record.save
        end
      end
    rescue => e
      harvest.update(status: 5, error: e.message )
    end
  end

  def self.create_records(harvest)
    begin
      harvest.update(status: 1)
      raw_records = RawRecord.where(harvest_id: harvest.id)
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
    rescue => e
      harvest.update(status: 5, error: e.message )
    end
  end

  def self.import_images(harvest)
    begin
      harvest.update(status: 2)
      region = 'us-east-2'
      s3 = Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
      bucket = s3.bucket('pacscl-production')
      import_repo_images(harvest, region, s3, bucket)
      clean_up_collection_imgs
    rescue => e
      harvest.update(status: 5, error: e.message )
    end
  end

  def self.index_records(harvest)
    begin
      harvest.update(status: 3)
      Sunspot.index!(harvest.records)
      harvest.update(status: 4)
    rescue => e
      harvest.update(status: 5, error: e.message )
    end
  end

  def self.import_repo_images(harvest, region=nil, s3=nil, bucket=nil)
    region ||= 'us-east-2'
    s3 ||= Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    bucket ||= s3.bucket('pacscl-production')
    CSV.parse(harvest.csv_file.download, headers: true) do |row|
      unless row[0].nil?
        @repository = Repository.find_by_name(row[2])
      end
    end
    import_images_from_harvest(harvest, region, s3, bucket)
  end

  def self.import_images_from_harvest(harvest, region=nil, s3=nil, bucket=nil)
    region ||= 'us-east-2'
    s3 ||= Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    bucket ||= s3.bucket('pacscl-production')
    repository = @repository
    repository ||= Repository.find(harvest.repository_id) if harvest.repository_id
    # TODO consider moving the S3 folder name into a field on Repository
    if repository
      case repository.short_name
      when "Barbara Bates Center"
        # import_from_bates(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Drexel University"
        # import_from_drexel(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Library Company"
        # import_from_libraryco(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Temple University"
        # import_from_temple(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "National Archives"
        # import_from_nara(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "University of Delaware"
        # import_from_udel(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "The German Society"
        # import_from_german(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Bryn Mawr College"
        # import_from_brynmawr(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "College of Physicians"
        # import_from_physicians(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Catholic Historical Research Center"
        # import_from_chrc(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Legacy Foundation"
        # import_from_union(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Alice Paul Institute"
        # import_from_alicepaul(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Chester County History Center"
        # import_from_cchs(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "United Lutheran Seminary"
        # import_from_unitedlutheran(harvest, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Swarthmore - Friends" || "Swarthmore - Peace"
        add_images_to_records(harvest.records, harvest.s3_images_folder)
      when "Haverford College"
        # add_images_to_records(harvest.records, 'Haverford',
        #                     image_relevance_test: Proc.new do |record,image_path,dc_identifier|
        #                       !record.oai_identifier.blank? && \
        #                         record.oai_identifier[0..39] == "oai:tricontentdm.brynmawr.edu:HC_DigReq/" && \
        #                         image_path.include?(record.oai_identifier[40..-1])
        #                     end)
        # import_from_haverford(harvest.records, region, s3, bucket)
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Presbyterian Historical Society"
        add_images_to_records(harvest.records, harvest.s3_images_folder, image_relevance_test: harvest.image_relevance_test)
      when "Historical Society of PA"
        add_images_to_records(harvest.records, harvest.s3_images_folder)
      when "PA State Archives"
        add_images_to_records(harvest.records, harvest.s3_images_folder)
      when "Port Washington Public Library"
        add_images_to_records(harvest.records, harvest.s3_images_folder)
      when "Athenaeum", "Chester County Archives and Record Services", "Princeton University", "Howard University", "Germantown Historical Society", "African American Museum in Philadelphia", "LaSalle University", "In Her Own Right"
        add_images_to_records(harvest.records, harvest.s3_images_folder)
      end
    end
  end

  def self.import_from_bates(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/Bates').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Bates/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Bates/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_drexel(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/Drexel').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Drexel/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Drexel/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        if dc_identifier.identifier[0..5] == "local:"
          image_paths.each do |image_path|
            if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier[7..-1])
              if image_path[-9..-1] == "thumb.png"
                record.thumbnail = "/#{image_path}"
              elsif image_path[-6..-1] == "lg.png"
                record.file_name = "/#{image_path}"
              end
              record.save
            end
          end
        end
      end
    end
  end

  def self.import_from_haverford(records, region=nil, s3=nil, bucket=nil)
    region = 'us-east-2'
    s3 = Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    bucket = s3.bucket('pacscl-production')

    all_repo_paths = bucket.objects(prefix: 'images/Haverford').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Haverford/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Haverford/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    records.each do |record|
      image_paths.each do |image_path|
        if !record.oai_identifier.blank? && record.oai_identifier[0..39] == "oai:tricontentdm.brynmawr.edu:HC_DigReq/"
          if !record.oai_identifier.blank? && image_path.include?(record.oai_identifier[40..-1])
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
        record.dc_identifiers.each do |dc_identifier|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            puts "got one! #{dc_identifier.identifier}"
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_libraryco(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/LibraryCompany').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/LibraryCompany/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/LibraryCompany/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      image_paths.each do |image_path|
        if !record.oai_identifier.blank? &&  image_path.include?(record.oai_identifier)
          if image_path[-9..-1] == "thumb.png"
            record.thumbnail = "/#{image_path}"
          elsif image_path[-6..-1] == "lg.png"
            record.file_name = "/#{image_path}"
          end
          record.save
        end
      end
    end
  end

  def self.import_from_temple(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/Temple').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Temple/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Temple/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if image_path.include?(dc_identifier.identifier) && !dc_identifier.identifier.blank?
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end


  def self.import_from_nara(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/NARA').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/NARA/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/NARA/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && (image_path[/NARA\/([^"]+)_lg.png/, 1] == dc_identifier.identifier || image_path[/NARA\/([^"]+)_thumb.png/, 1] == dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_udel(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/UDel').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/UDel/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/UDel/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end


  def self.import_from_german(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/GermanSociety').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/GermanSociety/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/GermanSociety/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if image_path.include?(dc_identifier.identifier) && !dc_identifier.identifier.blank?
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_brynmawr(harvest, region, s3, bucket)
    image_relevance_test = Proc.new do |record,image_path,dc_identifier|
      !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
    end

    all_repo_paths = bucket.objects(prefix: 'images/BrynMawr').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/BrynMawr/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/BrynMawr/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_chrc(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/CHRC').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/CHRC/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/CHRC/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_physicians(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/CollegeOfPhysicians').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/CollegeOfPhysicians/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/CollegeOfPhysicians/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_phs(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/PHS').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/PHS/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/PHS/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_union(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/UnionLeague').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/UnionLeague/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/UnionLeague/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_alicepaul(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/AlicePaul').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/AlicePaul/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/AlicePaul/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_cchs(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/CCHS').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/CCHS/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/CCHS/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.import_from_unitedlutheran(harvest, region, s3, bucket)
    all_repo_paths = bucket.objects(prefix: 'images/UnitedLutheran').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/UnitedLutheran/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/UnitedLutheran/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.add_images_to_records(records, images_folder, 
                            image_relevance_test: Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) } )
    raise "Please pass a proc to image_relevance_test with record and image_path as arguments" unless image_relevance_test.is_a?(Proc)
    region = 'us-east-2'
    s3 = Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
    bucket = s3.bucket('pacscl-production')

    s3_base = "images/#{images_folder}"
    all_repo_paths = bucket.objects(prefix: s3_base).collect(&:key)
    archive_paths = bucket.objects(prefix: "#{s3_base}/Archive").collect(&:key)
    failed_paths = bucket.objects(prefix: "#{s3_base}/Failed\ Inbox").collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if image_relevance_test.call(record, image_path, dc_identifier)
            if /_thumb.png\Z/.match(image_path)
              record.thumbnail = "/#{image_path}"
            elsif /_lg.png\Z/.match(image_path)
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  def self.clean_up_collection_imgs
    collection_records_with_images = Record.all.select { |r| r.is_collection? && (!r.file_name.nil? || !r.file_name.nil?) }
    collection_records_with_images.each do |r|
      r.update!(file_name: nil)
      r.update!(thumbnail: nil)
    end
  end
end
