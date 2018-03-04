class CreateHostDetails < ActiveRecord::Migration
  def up
    create_table :host_details do |t|
      t.references :user
      t.integer :activity_status, :default => 0

      t.timestamps null: true
    end
  end

  def down
    drop_table :host_details
  end
end
