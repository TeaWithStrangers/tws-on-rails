class AddHostProfileInfoToUserModel < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      # Something about them
      t.text :summary
      # What's your story?
      t.text :story
      # What might we talk about?
      t.text :topics
      # Tagline, akin to City Phrase
      t.text :tagline
    end

    change_table(:attendances) do |t|
      t.text :reason
    end
  end
end
