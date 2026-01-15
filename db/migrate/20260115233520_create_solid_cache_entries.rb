class CreateSolidCacheEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_cache_entries do |t|
      t.binary   :key,        null: false, limit: 1024
      t.binary   :value,      null: false, limit: 512.megabytes
      t.datetime :created_at, null: false

      t.index :key, unique: true, length: 1024
      t.index [ :key, :created_at ] # Optimization for cache cleanup
    end
  end
end
