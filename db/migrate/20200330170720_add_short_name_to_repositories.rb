class AddShortNameToRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :repositories, :short_name, :string
  end
end
