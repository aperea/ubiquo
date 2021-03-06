class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
      t.string   :type
      t.text     :metadata
    end
    add_index :versions, [:item_type, :item_id]
    add_index :versions, [:whodunnit]
  end

  def self.down
    remove_index :versions, [:item_type, :item_id]
    drop_table :versions
  end
end
