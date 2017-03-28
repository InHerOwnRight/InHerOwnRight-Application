class CreateDcSubject < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_subjects do |t|
      t.integer :record_id
      t.string :subject
      t.timestamps
    end
  end
end
