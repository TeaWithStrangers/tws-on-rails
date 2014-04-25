class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.string :city_code, :length => 3
      t.text :description
      t.text :tagline
      t.integer :brew_status

      t.timestamps
    end
  end
end
