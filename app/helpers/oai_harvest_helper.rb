require 'rake'
Rails.application.load_tasks

module OaiHarvestHelper

  def self.initiate(harvest)
    repo = harvest.repository || "TriColleges"
    if repo == "TriColleges"
      task_name = "tricolleges"
    else
      task_name = repo.oai_task
    end
    Delayed::Job.enqueue(DelayedRake.new("db:migrate"), queue: "oai_#{task_name}")
    begin
      self.create_raw_records(harvest, repo)
      self.delay(queue: "oai_#{task_name}").create_records(harvest)
      self.import_images(harvest, repo)
      self.delay(queue: "oai_#{task_name}").index_records(harvest)
    rescue => e
      harvest.update(status: 5, error: e.message )
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
        xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
        xml_doc.remove_namespaces!

        if record.save
          OaiHarvestRecord.create(record_id: record.id, oai_harvest_id: harvest.id)
          node_names = ["title", "mods/titleInfo", "date", "dateCreated", "creator", "name", "subject", "format", "type", "typeOfResource", "genre", "language", "language/languageTerm", "rights", "accessCondition",  "relation", "created", "licence", "identifier", "description", "abstract", "contributor", "publisher", "extent", "source", "spatial", "geographic", "text", "isPartOf", "relatedItem/titleInfo", "coverage", "spacial", "identifier.url"]
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
      Delayed::Job.enqueue(DelayedRake.new("import_images:swarthmore[#{harvest.id}]"), queue: "oai_tricolleges")
      Delayed::Job.enqueue(DelayedRake.new("import_images:clean_up_collection_imgs"), queue: "oai_tricolleges")
    else
      Delayed::Job.enqueue(DelayedRake.new("import_images:#{repo.image_task}[#{harvest.id}]"), queue: "oai_#{repo.oai_task}")
      Delayed::Job.enqueue(DelayedRake.new("import_images:clean_up_collection_imgs"), queue: "oai_#{repo.oai_task}")
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
