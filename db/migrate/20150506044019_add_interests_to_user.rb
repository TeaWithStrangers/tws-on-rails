class AddInterestsToUser < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.json :tws_interests
    end
  end
end
