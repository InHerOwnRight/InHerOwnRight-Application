class AddEnglishDateToDcDate < ActiveRecord::Migration[5.0]
  def change
    add_column :dc_dates, :english_date, :string
  end
end
