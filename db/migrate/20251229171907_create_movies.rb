class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.integer :tmdb_id
      t.string :title
      t.string :poster_url
      t.integer :release_year

      t.timestamps
    end
    add_index :movies, :tmdb_id, unique: true
  end
end
