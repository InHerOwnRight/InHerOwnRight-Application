class CreateDcResearchInterest < ActiveRecord::Migration[5.1]
  def change
    create_table :dc_research_interests do |t|
      t.integer :record_id
      t.text :research_interest

      t.timestamps
    end
  end
end
