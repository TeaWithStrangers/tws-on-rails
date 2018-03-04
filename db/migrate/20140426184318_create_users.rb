class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :name
      t.string :phone

      t.timestamps null: true
    end

    add_attachment :users, :avatar
  end

  def down
    drop_table :users
  end
end
