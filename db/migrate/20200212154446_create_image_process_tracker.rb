class CreateImageProcessTracker < ActiveRecord::Migration[5.0]
  def change
    create_table :image_process_trackers do |t|
      t.integer :files_processed
      t.integer :total_files
      t.integer :status, default: 0
    end
  end
end
