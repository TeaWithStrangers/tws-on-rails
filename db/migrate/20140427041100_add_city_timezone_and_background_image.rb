class AddCityTimezoneAndBackgroundImage < ActiveRecord::Migration
  def change
    change_table(:cities) do |t|
      t.string :timezone
    end

    add_attachment :cities, :header_bg
  end
end
