class CreateFailedInboxImages < ActiveRecord::Migration[5.0]
  def change
    create_table :failed_inbox_images do |t|
      t.string :image
      t.string :school
      t.string :action
      t.string :error
      t.datetime :failed_at
      t.boolean :current, default: true

      t.timestamps
    end
  end
end
