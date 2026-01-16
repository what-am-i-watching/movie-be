class AddDetailsToSolidCacheEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :solid_cache_entries, :key_hash, :integer, null: false
    add_column :solid_cache_entries, :byte_size, :integer, null: false
    add_index :solid_cache_entries, :key_hash, unique: true
    add_index :solid_cache_entries, [:key_hash, :byte_size]
  end
end
