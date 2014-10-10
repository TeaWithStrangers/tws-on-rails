class AddUserConfirmable < ActiveRecord::Migration
  def self.up
    add_column :users, :unconfirmed_email, :string
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    # add_column :users, :unconfirmed_email, :string # Only if using reconfirmable
    add_index :users, :confirmation_token, :unique => true

    # Grandfather in existing users
    User.update_all({
      :confirmed_at => DateTime.now, 
      :confirmation_sent_at => DateTime.now
    })
  end

  def self.down
    [:confirmed_at, :confirmation_token,
     :confirmation_sent_at, :unconfirmed_email].each do |c|
      remove_column :users,  c
    end
  end
end
