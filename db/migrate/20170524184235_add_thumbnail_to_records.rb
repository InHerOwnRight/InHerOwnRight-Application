class AddThumbnailToRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :records, :thumbnail, :string
  end
end
