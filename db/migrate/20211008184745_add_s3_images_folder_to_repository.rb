class AddS3ImagesFolderToRepository < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :s3_images_folder, :string
  end
end
