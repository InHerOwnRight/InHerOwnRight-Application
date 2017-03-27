class CreateRawRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :raw_records do |t|
      t.integer  :repository_id
      t.string   :original_record_url
      t.string   :oai_identifier
      t.string   :set_spec
      t.string   :original_entry_date
      t.text     :xml_metadata
      t.timestamps
    end
  end
end
