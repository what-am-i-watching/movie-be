class RemoveProgressNotesFromUserMovies < ActiveRecord::Migration[8.1]
  def change
    remove_column :user_movies, :progress_notes, :text
  end
end
