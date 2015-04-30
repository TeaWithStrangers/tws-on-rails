class RenameUserIdToHostId < ActiveRecord::Migration
  def change
    rename_column :tea_times, :user_id, :host_id
  end
end
