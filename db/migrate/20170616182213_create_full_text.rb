class CreateFullText < ActiveRecord::Migration[5.0]
  def change
    create_table :full_texts do |t|
      t.integer :record_id
      t.text :transcription
      t.timestamps
    end
  end
end
