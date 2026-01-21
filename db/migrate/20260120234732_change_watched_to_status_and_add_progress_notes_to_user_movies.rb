class ChangeWatchedToStatusAndAddProgressNotesToUserMovies < ActiveRecord::Migration[8.1]
  def up
    add_column :user_movies, :status, :integer, default: 0, null: false
    
    execute <<-SQL
      UPDATE user_movies
      SET status = CASE
        WHEN watched = true THEN 2
        WHEN watched = false THEN 0
        ELSE 0
      END
    SQL
    
    remove_column :user_movies, :watched
    
    add_column :user_movies, :progress_notes, :text
  end

  def down
    add_column :user_movies, :watched, :boolean, default: false
    
    execute <<-SQL
      UPDATE user_movies
      SET watched = CASE
        WHEN status = 2 THEN true
        ELSE false
      END
    SQL
    
    remove_column :user_movies, :status
    remove_column :user_movies, :progress_notes
  end
end
