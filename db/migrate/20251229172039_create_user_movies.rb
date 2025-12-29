class CreateUserMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :user_movies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.boolean :watched
      t.integer :rating
      t.text :notes

      t.timestamps
    end
  end
end
