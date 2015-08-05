class AddNotesColumnToTeaTimes < ActiveRecord::Migration
  def change
    add_column :tea_times, :notes, :text
  end
end
