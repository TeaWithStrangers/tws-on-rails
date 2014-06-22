class ProxyCities < ActiveRecord::Migration
  def change
    remove_column :cities, :proxy_city_id, :integer
    create_table :proxy_cities do |t|
      t.integer :city_id
      t.integer :proxy_city_id
    end

    add_index(:proxy_cities, [:city_id, :proxy_city_id], :unique => true)
    add_index(:proxy_cities, [:proxy_city_id, :city_id], :unique => true)
  end
end
