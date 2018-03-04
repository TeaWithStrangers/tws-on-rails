class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.references :tea_time
      t.references :user
      t.integer :status, :default => 0

      t.timestamps null: true
    end
  end
end
