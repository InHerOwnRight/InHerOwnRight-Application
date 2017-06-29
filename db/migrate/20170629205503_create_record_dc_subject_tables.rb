class CreateRecordDcSubjectTables < ActiveRecord::Migration[5.0]
  def change
    create_table :record_dc_subject_tables do |t|
      t.integer :record_id
      t.integer :dc_subject_id
    end
  end
end


