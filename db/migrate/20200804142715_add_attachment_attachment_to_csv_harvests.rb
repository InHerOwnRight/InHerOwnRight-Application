class AddAttachmentAttachmentToCsvHarvests < ActiveRecord::Migration[5.1]
  def self.up
    change_table :csv_harvests do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :csv_harvests, :attachment
  end
end
