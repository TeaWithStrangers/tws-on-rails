class CreateTeaTimes < ActiveRecord::Migration
  def change
    create_table :tea_times do |t|
      t.datetime :start_time
      t.float :duration
      t.integer :followup_status, :default => 0
      t.text :location
      t.belongs_to :city

      t.timestamps null: true
    end
  end
end
