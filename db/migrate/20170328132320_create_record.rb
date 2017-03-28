class CreateRecord < ActiveRecord::Migration[5.0]
  def change
    create_table :records do |t|
      t.integer :raw_record_id
      t.string :oai_identifier
      t.timestamps
    end
  end
end
