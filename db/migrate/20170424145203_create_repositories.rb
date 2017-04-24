class CreateRepositories < ActiveRecord::Migration[5.0]
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :address
      t.string :email
      t.string :url
    end
  end
end
