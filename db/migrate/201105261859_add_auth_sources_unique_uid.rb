class AddAuthSourcesAttrUniqueUid < ActiveRecord::Migration
  def self.up
    add_column :auth_source, :attr_unique_uid, :string
  end

  def self.down
    remove_column :auth_source, :attr_unique_uid
  end
end