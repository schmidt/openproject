class AddUsersRemoteUid < ActiveRecord::Migration
  def self.up
    add_column :users, :remote_uid, :string
  end

  def self.down
    remove_column :users, :remote_uid
  end
end