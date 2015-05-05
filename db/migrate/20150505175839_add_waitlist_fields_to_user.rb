class AddWaitlistFieldsToUser < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.timestamp :waitlisted_at
      t.timestamp :unwaitlisted_at
      t.boolean :waitlisted
    end
  end
end
