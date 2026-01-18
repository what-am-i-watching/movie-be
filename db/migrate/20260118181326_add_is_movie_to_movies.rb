class AddIsMovieToMovies < ActiveRecord::Migration[8.1]
  def up
    add_column :movies, :is_movie, :boolean

    Movie.update_all(is_movie: true)
  end

  def down
    remove_column :movies, :is_movie
  end
end
