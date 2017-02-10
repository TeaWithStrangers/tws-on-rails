class AddCommitmentToHostDetails < ActiveRecord::Migration
  def up
    add_column :host_details, :commitment, :integer
  end

  def down
    remove_column :host_details, :commitment, :integer
  end
end
