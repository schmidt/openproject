class AddUsersUniqueUid < ActiveRecord::Migration
  def self.up
    add_column :users, :unique_uid, :string
  end

  def self.down
    remove_column :users, :unique_uid
  end
end