class AddTaskFieldsToRepositories < ActiveRecord::Migration[5.1]
  def change
    add_column :repositories, :oai_task, :string
    add_column :repositories, :image_task, :string
  end
end
