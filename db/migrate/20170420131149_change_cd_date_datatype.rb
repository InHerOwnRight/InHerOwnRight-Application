class ChangeCdDateDatatype < ActiveRecord::Migration[5.0]
  def change
    change_column :dc_dates, :date, 'date USING CAST(date AS date)'
    add_column :dc_dates, :unprocessed_date, :string
  end
end
