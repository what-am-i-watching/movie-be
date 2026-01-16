class ChangeKeyHashToBigintInSolidCacheEntries < ActiveRecord::Migration[8.1]
  def change
    change_column :solid_cache_entries, :key_hash, :bigint, null: false
  end
end
