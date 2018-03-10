class ChangeHostDetailCommitmentDefault < ActiveRecord::Migration
  def change
    change_column :host_details, :commitment, :integer, :default => 0, :null => false
  end
end
