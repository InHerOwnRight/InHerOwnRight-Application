require "csv"
require 'delayed_rake.rb'

module OaiHarvestHelper

  REPO_OAI_CONVERSION = {"Temple University" => "temple",
                         "Barbara Bates Center" => "bates",
                         "Bryn Mawr College" => "tri_colleges",
                         "Swarthmore - Friends" => "tri_colleges",
                         "Haverford College" => "haverford",
                         "Library Company" => "library_co",
                         "Historical Society of PA" => "hsp",
                         "Drexel University" => "drexel",
                         "National Archives" => "nara",
                         "The German Society" => "german_society",
                         "University of Delaware" => "udel",
                         "College of Physicians" => "college_of_physicians",
                         "Presbyterian Historical Society" => "presbyterian",
                         "Swarthmore - Peace" => "tri_colleges",
                         "Catholic Historical Research Center" => "catholic" }

  REPO_IMAGE_CONVERSION = {"Temple University" => "temple",
                           "Barbara Bates Center" => "bates",
                           "Bryn Mawr College" => "bryn_mawr",
                           "Swarthmore - Friends" => "swarthmore",
                           "Haverford College" => "haverford",
                           "Library Company" => "library_co",
                           "Historical Society of PA" => "hsp",
                           "Drexel University" => "drexel",
                           "National Archives" => "nara",
                           "The German Society" => "german_society",
                           "University of Delaware" => "udel",
                           "College of Physicians" => "college_of_physicians",
                           "Presbyterian Historical Society" => "phs",
                           "Swarthmore - Peace" => "swarthmore",
                           "Catholic Historical Research Center" => "chrc" }

  def self.initiate(harvest)
    @harvest = harvest
    @repo = @harvest.repository
    Delayed::Job.enqueue(DelayedRake.new("db:migrate"), queue: "oai_#{@repo.short_name.downcase.gsub(" ", "_")}")
    create_raw_records
    delay(queue: "oai_#{@repo.short_name.downcase.gsub(" ", "_")}").create_records
    import_images
    delay(queue: "oai_#{@repo.short_name.downcase.gsub(" ", "_")}").index_records
  end

  def self.create_raw_records
    repo = REPO_OAI_CONVERSION[@repo.short_name]
    Delayed::Job.enqueue(DelayedRake.new("import_metadata:from_#{repo}"), queue: "oai_#{@repo.short_name.downcase.gsub(" ", "_")}")
  end

  def self.create_records
    @harvest.update(status: 1)
    raw_records = RawRecord.where(record_type: nil, updated_at: @harvest.created_at..DateTime.now)
    raw_records.each do |raw_record|
      if !raw_record.xml_metadata.blank?
        record = Record.find_or_initialize_by(oai_identifier: raw_record.oai_identifier)
        record.raw_record_id = raw_record.id
        record.oai_harvest = @harvest
        xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
        xml_doc.remove_namespaces!

        if record.save
          node_names = ["title", "date", "creator", "subject", "format", "type", "language", "rights", "relation", "created", "licence", "identifier", "description", "contributor", "publisher", "extent", "source", "spatial", "text", "isPartOf", "coverage", "spacial"]
          node_names.each do | node_name |
            record.create_dc_part(node_name, xml_doc, record)
          end
        end

        record.reload
      end
    end
  end

  def self.import_images
    @harvest.update(status: 2)
    repo = REPO_IMAGE_CONVERSION[@repo.short_name]
    Rake::Task["import_images:from_#{repo}"].invoke
    binding.pry
    # Delayed::Job.enqueue(DelayedRake.new("import_images:clean_up_collection_imgs"), queue: "oai_#{@repo.short_name.downcase.gsub(" ", "_")}")
  end

  def self.index_records
    @harvest.update(status: 3)
    @harvest.records.each do |record|
      Sunspot.index!(record)
    end
    @harvest.update(status: 4)
  end
end
