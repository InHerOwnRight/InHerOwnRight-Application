class AddFilenameToRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :records, :file_name, :string
  end
end
