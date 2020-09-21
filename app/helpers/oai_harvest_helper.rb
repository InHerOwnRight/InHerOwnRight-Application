require "csv"
require 'delayed_rake.rb'

module OaiHarvestHelper

  def self.initiate(harvest)
    repo = harvest.repository || "TriColleges"
    if repo == "TriColleges"
      Delayed::Job.enqueue(DelayedRake.new("db:migrate"), queue: "oai_tricolleges")
      begin
        self.create_raw_records(harvest, repo)
        self.delay(queue: "oai_tricolleges").create_records(harvest)
        self.import_images(harvest, repo)
        self.delay(queue: "oai_tricolleges").index_records(harvest)
      rescue => e
        harvest.update(status: 5, error: e.message )
      end
    else
      Delayed::Job.enqueue(DelayedRake.new("db:migrate"), queue: "oai_#{repo.oai_task}")
      begin
        self.create_raw_records(harvest, repo)
        self.delay(queue: "oai_#{repo.oai_task}").create_records(harvest)
        self.import_images(harvest, repo)
        self.delay(queue: "oai_#{repo.oai_task}").index_records(harvest)
      rescue => e
        harvest.update(status: 5, error: e.message )
      end
    end
  end

  def self.create_raw_records(harvest, repo)
    if repo == "TriColleges"
      Delayed::Job.enqueue(DelayedRake.new("import_metadata:tri_colleges[#{harvest.id}]"), queue: "oai_tricolleges")
    else
      Delayed::Job.enqueue(DelayedRake.new("import_metadata:#{repo.oai_task}[#{harvest.id}]"), queue: "oai_#{repo.oai_task}")
    end
  end

  def self.create_records(harvest)
    harvest.update(status: 1)
    raw_records = RawRecord.where(record_type: nil, harvest_id: harvest.id)
    raw_records.each do |raw_record|
      if !raw_record.xml_metadata.blank?
        record = Record.find_or_initialize_by(oai_identifier: raw_record.oai_identifier)
        record.raw_record_id = raw_record.id
        OaiHarvestRecord.create(record_id: record.id, oai_harvest_id: harvest.id)
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
    harvest.update(status: 2)
  end

  def self.import_images(harvest, repo)
    if repo == "TriColleges"
      Delayed::Job.enqueue(DelayedRake.new("import_images:swarthmore['#{harvest}']"), queue: "csv_tricolleges")
      Delayed::Job.enqueue(DelayedRake.new("import_images:haverford['#{harvest}']"), queue: "csv_tricolleges")
      Delayed::Job.enqueue(DelayedRake.new("import_images:brynmawr['#{harvest}']"), queue: "csv_tricolleges")
      Delayed::Job.enqueue(DelayedRake.new("import_images:clean_up_collection_imgs"), queue: "csv_tricolleges")
    else
      Delayed::Job.enqueue(DelayedRake.new("import_images:#{repo.image_task}['#{harvest}']"), queue: "csv_#{repo.oai_task}")
      Delayed::Job.enqueue(DelayedRake.new("import_images:clean_up_collection_imgs"), queue: "csv_#{repo.oai_task}")
    end
  end


  def self.index_records(harvest)
    harvest.update(status: 3)
    harvest.records.each do |record|
      Sunspot.index!(record)
    end
    harvest.update(status: 4)
  end
end
