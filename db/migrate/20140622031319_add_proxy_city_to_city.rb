class AddProxyCityToCity < ActiveRecord::Migration
  def change
    add_column :cities, :proxy_city_id, :integer
  end
end
