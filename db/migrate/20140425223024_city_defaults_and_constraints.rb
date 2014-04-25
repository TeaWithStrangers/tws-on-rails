class CityDefaultsAndConstraints < ActiveRecord::Migration
  def change
    add_index(:cities, :city_code, {name: 'city_code_idx', unique: true })
    change_column(:cities, :brew_status, :integer, :default => 0)
  end
end
