class RemoveDcIdentifiersStartingWithLocal < ActiveRecord::Migration[5.2]
  def up
    DcIdentifier.where("identifier LIKE 'local:%'").delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
