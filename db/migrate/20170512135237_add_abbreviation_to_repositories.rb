class AddAbbreviationToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :abbreviation, :string
  end
end
