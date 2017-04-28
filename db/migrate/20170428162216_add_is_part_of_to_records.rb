class AddIsPartOfToRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :records, :is_part_of, :string
  end
end
